# %%
import Gadfly as gf

p = plot(x = randn(2_000), Geom.histogram(bincount = 100))

plot(x = rand(100), y = rand(100))

# %%
