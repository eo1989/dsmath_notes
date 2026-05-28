





































import numpy as np
import pandas as pd
import hvplot.pandas  # noqa
import holoviews as hv
from holoviews import opts
import panel as pn

pn.extension(sizing_mode="stretch_width")



players_df = pd.read_json("data/players.json", encoding="unicode-escape")
events_df = pd.read_json("data/events/events_World_Cup.json")



events_df.head(2)



players_df.tail(2)










event_type_count = events_df["eventName"].value_counts()
event_type_distribution = event_type_count.hvplot.bar(
    title="Distribution of Event Types",
    height=400,
    responsive=True,
    rot=45,
)
event_type_distribution









opts.defaults(
    opts.Path(color="black"),
    opts.Rectangles(color=""),
    opts.Points(color="black", size=5),
)



# Set the dimensions of the field in meters
field_length = 105
field_width = 68
penalty_area_length = 16.5
penalty_area_width = 40.3
goal_area_length = 5.5
goal_area_width = 18.32
goal_width = 7.32
goal_depth = 2.44

pitch_plot_height = 550
pitch_plot_width = 800


# Helper function to create arcs
def create_arc(center, radius, start_angle, end_angle, clockwise=False):
    if clockwise:
        angles = np.linspace(np.radians(start_angle), np.radians(end_angle), 100)
    else:
        if start_angle < end_angle:
            start_angle += 360
        angles = np.linspace(np.radians(start_angle), np.radians(end_angle), 100)
    x = center[0] + radius * np.cos(angles)
    y = center[1] + radius * np.sin(angles)
    return hv.Path([np.column_stack([x, y])])


# create football pitch
def plot_pitch():
    pitch_elements = [
        hv.Rectangles([(0, 0, field_length, field_width)]),  # outer pitch rectangle
        hv.Ellipse(field_length / 2, field_width / 2, 18.3),  # center circle
        hv.Points([(field_length / 2, field_width / 2)]),  # center spot
        hv.Path([
            [(field_length / 2, 0), (field_length / 2, field_width)]
        ]),  # halfway line
        hv.Rectangles([
            (
                0,
                (field_width - penalty_area_width) / 2,
                penalty_area_length,
                (field_width + penalty_area_width) / 2,
            )
        ]),  # left penalty area
        hv.Rectangles([
            (
                field_length - penalty_area_length,
                (field_width - penalty_area_width) / 2,
                field_length,
                (field_width + penalty_area_width) / 2,
            )
        ]),  # right penalty area
        hv.Rectangles([
            (
                0,
                (field_width - goal_area_width) / 2,
                goal_area_length,
                (field_width + goal_area_width) / 2,
            )
        ]),  # left goal area
        hv.Rectangles([
            (
                field_length - goal_area_length,
                (field_width - goal_area_width) / 2,
                field_length,
                (field_width + goal_area_width) / 2,
            )
        ]),  # right goal area
        hv.Points([(11, field_width / 2)]),  # left penalty spot
        hv.Points([(field_length - 11, field_width / 2)]),  # right penalty spot
        create_arc((11, field_width / 2), 9.15, 52, 308),  # left penalty arc
        create_arc(
            (field_length - 11, field_width / 2), 9.15, 232, 128
        ),  # right penalty arc
        hv.Rectangles([
            (
                -goal_depth,
                (field_width - goal_width) / 2,
                0,
                (field_width + goal_width) / 2,
            )
        ]),  # left goal
        hv.Rectangles([
            (
                field_length,
                (field_width - goal_width) / 2,
                field_length + goal_depth,
                (field_width + goal_width) / 2,
            )
        ]),  # right goal
        hv.Arrow(
            20,
            5,
            "",
            ">",
        ),  # attack arrow
        hv.Text(10, 6, "Attack", 11),  # attack text
    ]

    field = hv.Overlay(pitch_elements).opts(
        frame_width=pitch_plot_width,
        frame_height=pitch_plot_height,
        xlim=(-5, field_length + 5),
        ylim=(-5, field_width + 5),
        xaxis=None,
        yaxis=None,
    )
    return field



pitch = plot_pitch()
pitch









def transform_positions(events_df, field_length, field_width):
    def scale_position(pos):
        scaled_positions = []
        for p in pos:
            scaled_p = {
                "x": p["x"] * field_length / 100,
                "y": p["y"] * field_width / 100,
            }
            scaled_positions.append(scaled_p)
        return scaled_positions

    events_df["positions"] = events_df["positions"].apply(scale_position)
    return events_df



events_df = transform_positions(events_df, field_length, field_width)
events_df.head(2)





def plot_event_heatmap(events_df, event_type, cmap="Greens"):
    """
    Plots a heatmap of the specified event type on a football pitch.

    Parameters:
    events_df (pd.DataFrame): The dataframe containing event data with the following columns:
        - eventId: The identifier of the event's type.
        - eventName: The name of the event's type.
        - subEventId: The identifier of the subevent's type.
        - subEventName: The name of the subevent's type.
        - tags: A list of event tags describing additional information about the event.
        - eventSec: The time when the event occurs (in seconds since the beginning of the current half).
        - id: A unique identifier of the event.
        - matchId: The identifier of the match the event refers to.
        - matchPeriod: The period of the match (1H, 2H, E1, E2, P).
        - playerId: The identifier of the player who generated the event.
        - positions: The origin and destination positions associated with the event.
        - teamId: The identifier of the player's team.
    event_type (str): The type of event to plot from the eventName column.
    cmap (str): The color map to use for the heatmap. Default is 'Greens'.

    Returns:
    hvPlot object: A heatmap plot of the specified event type overlaid on a football pitch.
    """
    event_type = event_type.lower()
    event = events_df[events_df["eventName"].str.lower() == event_type]
    positions = [
        (pos[0]["x"], pos[0]["y"]) for pos in event["positions"] if len(pos) > 0
    ]
    event_df = pd.DataFrame(positions, columns=["x", "y"])
    pitch = plot_pitch()
    title = f"{event_type.capitalize()} Heatmap for All Players"

    event_heatmap = event_df.hvplot.hexbin(
        x="x", y="y", cmap=cmap, min_count=1, title=title
    )

    event_heatmap_plot = (event_heatmap * pitch).opts(
        frame_width=pitch_plot_width,
        frame_height=pitch_plot_height,
        xlim=(-5, 110),
        ylim=(-5, 73),
        xaxis=None,
        yaxis=None,
    )

    return event_heatmap_plot





passes_map = plot_event_heatmap(events_df, "pass")
passes_map










event_type = list(events_df["eventName"].unique())
event_type_selector = pn.widgets.Select(name="Event Type", options=event_type)
event_heatmap = pn.bind(
    plot_event_heatmap, events_df=events_df, event_type=event_type_selector
)

pn.Column(event_type_selector, event_heatmap)











def find_top_players(events_df, players_df, event_type, top_n=10):
    """
    Finds the top players for a given event type.

    Parameters:
    events_df (pd.DataFrame): The dataframe containing event data.
    players_df (pd.DataFrame): The dataframe containing player data.
    event_type (str): The type of event to filter by.
    top_n (int): The number of top players to return.

    Returns:
    pd.DataFrame: A dataframe containing the top players for the given event type.
    """
    event_type = event_type.lower()
    event = events_df[events_df["eventName"].str.lower() == event_type]
    event_counts = (
        event.groupby("playerId").size().reset_index(name=f"{event_type} count")
    )

    top_players = event_counts.sort_values(
        by=f"{event_type} count", ascending=False
    ).head(top_n)
    top_players = top_players.merge(players_df, left_on="playerId", right_on="wyId")
    top_players.set_index("playerId", inplace=True)

    return top_players[["shortName", f"{event_type} count"]]





pass_maestros = find_top_players(events_df, players_df, "pass")
pass_maestros





def plot_top_players(events_df, players_df, event_type, top_n=10):
    """
    Plots a bar chart of the top players for a given event type.

    Parameters:
    events_df (pd.DataFrame): The dataframe containing event data.
    players_df (pd.DataFrame): The dataframe containing player data.
    event_type (str): The type of event to filter by.
    top_n (int): The number of top players to return.

    Returns:
    hvPlot: A bar chart of the top players for the given event type.
    """
    top_players = find_top_players(events_df, players_df, event_type, top_n)
    event_type = event_type.lower()

    title = f"Top {top_n} Players for {event_type.capitalize()}"

    bar_plot = top_players.hvplot.bar(
        title=title,
        x="shortName",
        y=f"{event_type} count",
        xlabel="",
        ylabel=f"Number of {event_type}",
        rot=45,
        color="#177F3B",
    )

    return bar_plot



pass_maestros_plot = plot_top_players(events_df, players_df, "pass")
pass_maestros_plot






top_n_selector = pn.widgets.IntSlider(name="Top", start=1, end=20, value=10)


bar_chart = pn.bind(
    plot_top_players,
    events_df=events_df,
    players_df=players_df,
    event_type=event_type_selector,
    top_n=top_n_selector,
)

pn.Column(pn.Row(top_n_selector, event_type_selector), bar_chart)







def get_player_id(player_name):
    player_name_to_id = dict(zip(players_df["shortName"], players_df["wyId"]))
    return player_name_to_id.get(player_name)


def plot_player_events(events_df, players_df, player_name):
    """
    Plots a distribution of events performed by a specific player on a football pitch.

    Parameters:
    events_df (pd.DataFrame): The dataframe containing event data.
    players_df (pd.DataFrame): The dataframe containing player data.
    player_name (str): The name of the player to plot events for.

    Returns:
    hvPlot object: A scatter plot of the player's events overlaid on a football pitch.
    """
    pitch = plot_pitch()
    if not player_name:
        return pn.Column(
            pn.pane.Markdown("## Start typing a player name above."), pitch
        )

    player_id = get_player_id(player_name)
    if player_id is None:
        return pn.Column(pn.pane.Markdown("## Please select a valid player."), pitch)

    player_events = events_df[events_df["playerId"] == player_id]

    if player_events.empty:
        return pn.Column(
            pn.pane.Markdown(f"## No events found for {player_name}."), pitch
        )

    positions = [
        (pos[0]["x"], pos[0]["y"], event)
        for pos, event in zip(player_events["positions"], player_events["eventName"])
        if len(pos) > 0
    ]
    event_df = pd.DataFrame(positions, columns=["x", "y", "eventName"])

    event_scatter = event_df.hvplot.points(
        x="x",
        y="y",
        c="eventName",
        cmap="Category20",
        title=f"All Events for Player: {player_name}",
    )

    player_scatter = (event_scatter * pitch).opts(
        frame_width=pitch_plot_width,
        frame_height=pitch_plot_height,
        xlim=(-5, 110),
        ylim=(-5, 73),
        xaxis=None,
        yaxis=None,
        legend_position="top",
    )

    return player_scatter



isco_map = plot_player_events(events_df, players_df, "Isco")
isco_map






player_name_selector = pn.widgets.AutocompleteInput(

    name="Player Name",
    options=list(players_df["shortName"]),
    placeholder="Type player name...",
    case_sensitive=False,
    search_strategy="includes",
    value="L. Messi",
)

player_events = pn.bind(
    plot_player_events,
    events_df=events_df,
    players_df=players_df,
    player_name=player_name_selector,
)

pn.Column(player_name_selector, player_events)







def plot_player_pass_trajectory(events_df, players_df, player_name):
    player_id = get_player_id(player_name)
    pitch = plot_pitch()

    if player_id is None:
        return pn.Column(pn.pane.Markdown("## Please select a valid player."), pitch)

    player_events = events_df[events_df["playerId"] == player_id]

    if player_events.empty:
        return pn.Column(
            pn.pane.Markdown(f"## No events found for {player_name}."), pitch
        )

    passes = player_events[player_events["eventName"].str.lower() == "pass"]

    if passes.empty:
        return pn.Column(
            pn.pane.Markdown(f"## No passes found for {player_name}."), pitch
        )

    pass_positions = [
        (pos[0]["x"], pos[0]["y"]) for pos in passes["positions"] if len(pos) > 1
    ]
    pass_df = pd.DataFrame(pass_positions, columns=["x", "y"])

    pass_scatter = pass_df.hvplot.points(
        x="x",
        y="y",
        color="#1D78B4",
        title=f"Click for Pass Trajectories of {player_name}",
    )
    total_passes = hv.Text(
        75, 70, f"Total number of passes: {len(pass_df)}", halign="center", fontsize=12
    )

    # Callback to filter passes based on click location
    def filter_passes(x, y, radius=1.5):
        filtered_passes = passes[
            (passes["positions"].apply(lambda pos: pos[0]["x"]) >= x - radius)
            & (passes["positions"].apply(lambda pos: pos[0]["x"]) <= x + radius)
            & (passes["positions"].apply(lambda pos: pos[0]["y"]) >= y - radius)
            & (passes["positions"].apply(lambda pos: pos[0]["y"]) <= y + radius)
        ]

        if filtered_passes.empty:
            return hv.Overlay()

        pass_lines = []
        for pos in filtered_passes["positions"]:
            pass_lines.append(
                hv.Segments([
                    (pos[0]["x"], pos[0]["y"], pos[1]["x"], pos[1]["y"])
                ]).opts(color="green", line_width=2, line_alpha=0.5)
            )
        pass_lines_overlay = hv.Overlay(pass_lines)

        return pass_lines_overlay

    # Create a stream for handling clicks
    stream = hv.streams.Tap(source=pass_scatter, x=52, y=34)
    dynamic_pass_lines = hv.DynamicMap(
        lambda x, y: filter_passes(x, y), streams=[stream]
    )

    dynamic_map = pitch * pass_scatter * total_passes * dynamic_pass_lines

    return dynamic_map.opts(
        frame_width=pitch_plot_width,
        frame_height=pitch_plot_height,
        xlim=(-5, 110),
        ylim=(-5, 73),
        xaxis=None,
        yaxis=None,
    )







player_pass_scatter = pn.bind(
    plot_player_pass_trajectory,
    events_df=events_df,
    players_df=players_df,
    player_name=player_name_selector,
)

pn.Column(player_name_selector, player_pass_scatter, sizing_mode="stretch_width")










all_players_tab = pn.Column(
    pn.Row(event_type_selector, top_n_selector),
    bar_chart,
    event_heatmap,
    sizing_mode="stretch_both",
)

player_event_tab = pn.Column(
    player_name_selector,
    player_events,
    player_pass_scatter,
    sizing_mode="stretch_both",
)

layout = pn.Tabs(("All Players", all_players_tab), ("Per Player", player_event_tab))
layout








logo = '<img src="https://upload.wikimedia.org/wikipedia/en/6/67/2018_FIFA_World_Cup.svg" style="display: block; margin: 0 auto;">'

text = """ Explore the 2018 FIFA World Cup with interactive visualizations built with `hvPlot` and `Panel` from [HoloViz](https://holoviz.org/)."""

template = pn.template.FastListTemplate(
    header_background="#177F3B",
    title="2018 FIFA World Cup Dashboard",
    sidebar=[logo, text],
    main=[layout],
    main_layout=None,
    main_max_width="800px",
)
template.servable()
