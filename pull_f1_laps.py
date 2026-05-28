from pathlib import Path

import fastf1
import pandas as pd

# REPO = Path(__file__).resolve().parents[1]
REPO = Path(__file__).cwd()
CACHE = REPO / ".cache" / "fastf1"
OUT = REPO / "data" / "f1_laps.csv"

CACHE.mkdir(parents=True, exist_ok=True)
OUT.parent.mkdir(parents=True, exist_ok=True)
fastf1.Cache.enable_cache(str(CACHE))

RACES = [
    ("Bahrain Grand Prix", "Bahrain"),
    ("Monaco Grand Prix", "Monaco"),
    ("British Grand Prix", "Britain"),
    ("Spanish Grand Prix", "Spain"),
]

cols = {
    "Driver": "driver",
    "Team": "team",
    "Compound": "compound",
    "TyreLife": "tyre_life",
    "LapNumber": "lap_number",
    "Stint": "stint",
    "Position": "position",
    "AirTemp": "air_temp",
    "TrackTemp": "track_temp",
    "Humidity": "humidity",
    "WindSpeed": "wind_speed",
    "lap_time_s": "lap_time_s",
}


def pull_race(
    venue_name: str,
    venue_label: str,
) -> pd.DataFrame:
    session = fastf1.get_session(2025, venue_name, "R")
    session.load(laps=True, telemetry=False, weather=True, messages=False)

    laps = session.laps.copy().sort_values("Time")
    weather = session.weather_data.copy().sort_values("Time")
    merged = pd.merge_asof(
        laps,
        weather,
        on="Time",
        direction="nearest",
        tolerance=pd.Timedelta("3min"),
    )

    clean = merged[
        merged["PitOutTime"].isna()
        & merged["PitInTime"].isna()
        & (merged["Deleted"] != True)
        & (merged["IsAccurate"] == True)
        & merged["LapTime"].notna()
    ].copy()
    clean["lap_time_s"] = clean["LapTime"].dt.total_seconds()

    df: pd.DataFrame = clean[list(cols)].rename(columns=cols)
    for c in ["tyre_life", "lap_number", "stint", "position"]:
        df[c] = df[c].astype("int")

    # Per-race median filter. Doing this globally would either drop legitimate
    # Monaco laps (median ~75s, far below pooled median) or keep Monza
    # 'outliers' relative to the slower pool.
    median_t = df["lap_time_s"].median()
    df = df[
        (df["lap_time_s"] >= 0.90 * median_t)
        & (df["lap_time_s"] <= 1.30 * median_t)
    ].copy()

    df["venue"] = venue_label
    return df


frames = []
for venue_name, venue_label in RACES:
    print(f"loading {venue_name}...", flush=True)
    df = pull_race(venue_name, venue_label)
    print(
        f"\t{venue_label}: {len(df)} clean laps, median {df['lap_time_s'].median():.2f}s"
    )
    frames.append(df)


combined = pd.concat(frames, ignore_index=True)
combined.to_csv(OUT, index=False)

print(
    f"wrote {OUT.relative_to(REPO)}: {len(combined)} rows, {OUT.stat().st_size} bytes"
)
print(
    "per-venue row counts:\n",
    combined["venue"].value_counts().to_string(),
    "\ncompound counts:\n",
    combined["compound"].value_counts().to_string(),
)
