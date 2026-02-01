# %%
using DifferentialEquations
using Plots
plotly()


α = 0.75
β = 0.1

# %% [markdown]
#
# $du = f(\mu, \rho, \tau)d\tau + g(\mu, \rho, \tau)dW$
#
# %%

du = f(μ, ρ, τ)dτ + g(μ, ρ, τ)
f(μ, ρ, τ) = α * μ
g(μ, ρ, τ) = β * μ


u0 = 1.0

t0 = 0.0
t1 = 1.0

tspan = (t0, t1)
step = 0.0001

# %%
prob_ODE = ODEProblem(f, u0, tspan)
prob_SDE = SDEProblem(f, g, u0, tspan)


sol_ODE = solve(prob_ODE)
sol_SDE = solve(prob_SDE, EM(), dt = step)


# %%
const g = 9.81  # gravity

function pendulum(du, μ, τ, ρ)
    du[1] = μ[2]
    du[2] = -g * sin(μ[1])
end

u0 = [3.0, 0.0];  # init state
tt = (0.0, 10.0); # time interval
ps = [1.0];       # parameters

# prob = ODEProblem(pendulum, u0, tt, ps)
sol = solve(ODEProblem(pendulum, u0, tt, ps))

plot!(sol)
# θ = [sol]
# %%


