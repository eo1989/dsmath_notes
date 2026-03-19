#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# using Flux, NeuralPDE, Plots
using NeuralPDE, Plots
import Lux as Lx
import StochasticDiffEq as SDE
using Metal

Metal.allowscaler(false)  # recommended to catch accidental CPU fallback

function maybe_gpu_metal(model, ps, st)
    if Metal.functional()    # :contentReference[oaicite:4]{index = 4}
        return Lx.

    end
end

#
#
#
#
#
#
function phi(xi)
    y = Float64[]
    K = 100
    for x in eachcol(xi)
        val = max(K - maximum(x), 0.00)
        y = push!(y, val)
    end
    y = reshape(y, 1, size(y)[1])
    return y
end
#
#
#
#
d = 1
r = 0.035
sigma = 0.2
xspan = (80.00, 115.00)
tspan = (0.0, 1.0)
σ(du, u, p, t) = du .= sigma .* u
\mu(du, u, p, t) = du .= r .* u
prob =
#
#
#
