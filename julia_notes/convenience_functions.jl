"""
These are convenience functions from Algorithms for Decision Making (2022, MIT Press).
They're helpful when working with dictionaries and named tuples.
"""

using Distributions, LinearAlgebra, GridInterpolations

# Defining `SetCategorical` to represent distributions over discrete sets:
struct SetCategorical{S}

    function Base.Dict{Symbol,V}(a::NamedTuple) where {V}
        Dict{Symbol,V}(n => v for (n, v) in zip(keys(a), values(a)))
    end

    Base.convert(::Type{Dict{Symbol,V}}, a::NamedTuple) where {V} =
        Dict{Symbol,V}(a)

    function Base.isequal(a::Dict{Symbol,<:Any}, nt::NamedTuple)
        length(a) == length(nt) && all(a[n] == v for (n, v) in zip(keys(nt), values(nt)))
    end

    # struct SetCategorical{S}
    elements::Vector{S}  # set of elements (could be repeated)
    distr::Categorical   # categorical distribution over set elements 

    function SetCategorical(elements::AbstractVector{S}) where {S}
        weights = ones(length(elements))
        return new{S}(elements, Categorical(normalize(weights, 1)))
    end

    function SetCategorical(
        elements::AbstractVector{S},
        weights::AbstractVector{Float64},
    ) where {S}
        ł₁ = norm(weights, 1)
        if ł₁ < 1e-6 || isinf(ł₁)
            return SetCategorical(elements)
        end
        distr = Categorical(normalize(weights, 1))
        return new{S}(elements, distr)
    end
    # end

end

Distributions.rand(D::SetCategorical) = D.elements[rand(D.distr)]
Distributions.rand(D::SetCategorical, n::Int) = D.elements[rand(D.distr, n)]
function Distributions.pdf(D::SetCategorical, x)
    sum(e == x ? w : 0.0 for (e, w) in zip(D.elements, D.distr.p))
end

end

# Testing them:

# a = Dict{Symbol,Integer}((a = 1, b = 2, c = 3))

# isequal(a, (a = 1, b = 2, c = 3))
# isequal(a, (a = 1, c = 3, b = 2))

# Dict{Dict{Symbol,Integer},Float64}((a = 1, b = 1) => 0.2, (a = 1, b = 2) => 0.8)

# D = SetCategorical(["up", "down", "left", "right"], [0.4, 0.2, 0.3, 0.1]);
# rand(D)
# rand(D, 5)
# pdf(D, "up")
