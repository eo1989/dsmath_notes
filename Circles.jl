abstract type Circle end

struct FloatingCircle <: Circle
    r::Real
end

struct PositionedCircle <: Circle
    x::Real
    y::Real
    r::Real
end

println(subtypes(Circle))
