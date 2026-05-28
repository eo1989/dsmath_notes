







































using Pkg; pkgs = ["Distributions", "Interpolations", "Polynomials", "QuadGK",
"StatsPlots"]; all(haskey.(Ref(Pkg.project().dependencies), pkgs)) || Pkg.add(pkgs)
using LinearAlgebra, Statistics
using Distributions, QuadGK, Polynomials, Interpolations
using StatsPlots












using Distributions
x = 1
y = Normal()
z = "foo"
@show x, y, z
@show typeof(x), typeof(y), typeof(z),
@show supertype(typeof(x))


# pipe operator, |>, is is equivalent
@show typeof(x) |> supertype
@show supertype(typeof(y))
@show typeof(z) |> supertype
@show typeof(x) <: Any;







# using Base: show_supertypes  # import the function from `Base`
# show_supertypes(Int64)

println(Int64 <:)




subtypes(Integer)
