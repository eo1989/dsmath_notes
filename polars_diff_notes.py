# %%
import numpy as np

import polars as pl

# %%


def calc_ma(
    data: pl.DataFrame, window: int, column: str = "close"
) -> pl.Series:
    return data[column].rolling_mean(window)


def gen_signals(data: pl.DataFrame) -> pl.DataFrame:
    data = data.with_columns([
        pl.col("close").rolling_mean(10).alias("MA_short"),
        pl.col("close").rolling_mean(30).alias("MA_long"),
    ])

    data = data.with_columns([
        (pl.col("MA_short") > pl.col("MA_long")).cast(pl.Int8).alias("signal")
    ])

    return data


# %%
