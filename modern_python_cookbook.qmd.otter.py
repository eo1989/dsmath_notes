






















r, g, b =  (hx_int >> 16) & 0xFF, (hx_int >> 8) & 0xFF, hx_int & 0xFF






def hex2rgb_1(hx_int):
    if isinstance(hx_int, str):
        if hx_int[0] == "#":
            hx_int = int(hx_int[1:], 16)
        else:
            hx_int = int(hx_int, 16)

    r, g, b = (hx_int >> 16) & 0xFF, (hx_int >> 8) & 0xFF, hx_int & 0xFF
    return r, g, b




def hex2rgb_1(hx_int: int | str) -> tuple[int, int, int]:
    if isinstance(hx_int, str):
        if hx_int[0] == "#":
            hx_int = int(hx_int[1:], 16)
        else:
            hx_int = int(hx_int, 16)

    r, g, b = (hx_int >> 16) & 0xFF, (hx_int >> 8) & 0xFF, hx_int & 0xFF
    return r, g, b






def rgb_to_hsl_1(rgb: tuple[int, int, int]) -> tuple[float, float, float]:
    ...

def hsl_comp_t(hsl: tuple[float, float, float]) -> tuple[float, float, float]:
    ...

def rgb_to_hsl_t(rgb: tuple[float, float, float]) -> tuple[int, int, int]:
    ...



from typing import TypeAlias


RGB_a: TypeAlias = tuple[int, int, int]
HSL_a: TypeAlias = tuple[float, float, float]

def rgb_to_hsl(color: RGB_a) -> HSL_a:
    ...

def hsl_complement(color: HSL_a) -> HSL_a:
    ...

def hsl_to_rgb(color: HSL_a) -> RGB_a:
    ...



from typing import NamedTuple

class RGB(NamedTuple):

    red: int
    green: int
    blue: int













import random

def die() -> int:
    """Roll a random value between 1 and 6 for a six-sided die."""
    return random.randint(1, 6)

def craps() -> tuple[int, int]:
    return (die(), die())




def zonk() -> tuple[int, ...]:
    # return tuple(die() for x in range(6))
    return tuple(die() for _ in range(6))





def craps_v2() -> tuple[int, ...]:
    # return tuple(die() for x in range(n))
    return tuple(die() for _ in range(2))






def dice_v2(n: int) -> tuple[int, ...]:
    return tuple(die() for _ in range(n))





def dice_v3(n: int = 2) -> tuple[int, ...]:
    return tuple(die() for _ in range(n))








































from random import randint


class Dice:
    def __init__(self) -> None:
        self.faces: tuple[int, int] = (0, 0)

    def roll(self) -> None:
        self.faces = (randint(1, 6), randint(1, 6))

    def total(self) -> int:
        return sum(self.faces)

    def hardway(self) -> bool:
        return self.faces[0] == self.faces[1]

    def easyway(self) -> bool:
        return self.faces[0] != self.faces[1]
















import json
from pathlib import Path

import matplotlib.pyplot as plt
from pydantic import BaseModel

source_path = Path.cwd().parent.parent / "Downloads" / "anscombe.json"

with source_path.open() as source_file:
    all_data = json.load(source_file)
[data["series"] for data in all_data]



all_data[0]["data"]




class Pair(BaseModel):
    x: float
    y: float


class Series(BaseModel):
    series: str
    data: list[Pair]

    @property
    def x(self) -> list[float]:
        """The x property."""
        return [p.x for p in self.data]

    @property
    def y(self) -> list[float]:
        """The y property."""
        return [p.y for p in self.data]






plt.figure(layout="tight")
for n, series in enumerate(quartet.values(), start=1):
    title = f"Series {series.series}"
    plt.subplot(2, 2, n)
    plt.scatter(series.x, series.y)
    plt.title(title)
    plt.show()





source = Path.cwd().parent.parent / "Downloads" / "anscombe.json"

with source.open() as source_file:
    json_doc = json.load(source_file)
    quartet = {s.series: s for s in source_data}
    source_data = (Series.model_validate(s) for s in json_doc)







x = [p.x for p in quartet["I"].data]

y = [p.y for p in quartet["I"].data]

plt.scatter(x, y)
plt.title(f"Series {quartet['I'].series}")
plt.show()





import json
import statistics as stats
from pathlib import Path

from pydantic import BaseModel


class Pair(BaseModel):
    x: float
    y: float


class Series(BaseModel):
    series: str
    data: list[Pair]

    @property
    def x(self) -> list[float]:
        """The x property."""
        return [p.x for p in self.data]

    @property
    def y(self) -> list[float]:
        """The y property."""
        return [p.y for p in self.data]

    @property
    def correlation(self) -> float:
        return stats.correlation(self.x, self.y)

    @property
    def regression(self) -> tuple[float, float]:
        return stats.linear_regression(self.x, self.y)




print(f"{quartet['I'].correlation:.4f}")



r = quartet["I"].regression
f"y = {r.slope:.1f}*x + {r.intercept:.1f}"










fig = plt.figure(layout="tight")
ax_dict = fig.subplot_mosaic(
    [
        ["I", "II"],
        ["III", "IV"],
    ],
)

for name, ax in ax_dict.items():
    series = quartet[name]
    ax.scatter(series.x, series.y)
    ax.set_title(f"Series {name}")
    lr = series.regression
    eq1 = rf"$r = {series.correlation:.3f}$"
    eq2 = rf"$Y = {lr.slope:.1f} \times X + {lr.intercept:.2f}$"
    ax.text(
        0.95,
        0.05,
        f"{eq1}\n{eq2}",
        fontfamily="sans-serif",
        horizontalalignment="right",
        verticalalignment="bottom",
        transform=ax.transAxes,
    )
    ax.axline((0, lr.intercept), slope=lr.slope)

plt.show()







from IPython.display import Markdown, display

m = Markdown(rf"""
We can see that $r = {quartet["I"].correlation:.2f}$; this is a strong
correlation.


This leads to a linear regression result with $y = {r.slope:.1f}
\times X + {r.intercept:.1f}$ as the best fit

for this collection of samples.

Interestingly, this is true for all four series in spite of the dramatically
distinct scatter plots.

""")
display(m)







def ingest(source: Path) -> dict[str, Series]:
    """
    doctest example
    """

    with source.open() as source_file:
        json_documnet = json.load(source_file)
        source_data = (Series.model_validate(s) for s in json_documnet)
        quartet = {s.series: s for s in source_data}

    return quartet



sourse = Path.cwd().parent.parent / "Downloads" / "anscombe.json"
quartet = ingest(sourse)



assert len(quartet) == 4, f"read {len(quartet)} series"

assert list(quartet.keys()) == ["I", "II", "III", "IV"], (
    f"keys were {list(quartet.keys())}"
)




from math import isclose

test = Series(
    series="test", data=[Pair(x=2, y=4), Pair(x=3, y=6), Pair(x=5, y=10)]
)

assert isclose(test.correlation, 1.0)

assert isclose(test.regression.slope, 2.0)

assert isclose(test.regression.intercept, 0.0)
