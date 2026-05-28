using Distributions, StatsBase, Random, Plots, LaTeXStrings;
import Plots: mm
default(; dpi = 500)
pyplot();

plt_axes = plot()

plot!(plt_axes,
      xguide = "x axis guide (label)",
      yguide = "y axis guide (label)",
      xlims = (0, 1),
      ylims = (0, 1),
      ticks = 
      )
