using GLMakie

# base.@kwdef mutable struct lorenz

@kwdef mutable struct Lorenz
    dt::Float64 = 0.01
    σ::Float64 = 10
    ρ::Float64 = 28
    β::Float64 = 8 / 3
    x::Float64 = 1
    y::Float64 = 1
    z::Float64 = 1
end

function step!(l::Lorenz)
    dx = l.σ * (l.y - l.x)
    dy = l.x * (l.ρ - l.z) - l.y
    dz = l.x * l.y - l.β * l.z

    l.x += dx * l.dt
    l.y += dy * l.dt
    l.z += dz * l.dt
    Point3f(l.x, l.y, l.z)
end

attractor = Lorenz()

points = Point3f[]
colors = Int[]

set_theme!(theme_black())

fig, ax, l = lines(points, color=colors,
    colormap=:inferno, transparency=true,
    axis=(; type=Axis3, protrusions=(0, 0, 0, 0),
        viewmode=:fit, limits=(-30, 30, -30, 30, 0, 50)))

record(fig, "lorenz_example.mp4", 1:120) do frame
    for i in 1:100
        push!(points, step!(attractor))
        push!(colors, frame)
    end
    ax.azimuth[] = 1.7pi + 0.3 * sin(2pi * frame / 240)
    Makie.update!(l, arg1=points, color=colors)
    l.colorrange = (0, frame)
end
