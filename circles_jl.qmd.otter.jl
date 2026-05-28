














abstract type Circle end

struct FloatingCircle <: Circle
    r::Real
end



supertypes(FloatingCircle)



struct PositionedCircle <: Circle
    x::Real
    y::Real
    r::Real
end



subtypes(Circle)



function circle_area(c::Circle)
    return π * c.r^2
end





c1 = FloatingCircle(1)



c1.r



circle_area(c1)



c2 = PositionedCircle(2, 2, 1)



c2.x, c2.y



c2.r



circle_area(c2)



circle_area(21)







function is_inside(c1::PositionedCircle, c2::PositionedCircle)
    d = sqrt((c2.x - c1.x)^2 + (c2.y - c1.y)^2)
    return d + c2.r < c1.r  # true if c2 is inside c2
end



a = PositionedCircle(2, 2, 2)
println(a)
b = PositionedCircle(1, 1, 0.5)
println(b)



is_inside(a, b)



c = PositionedCircle(3, 3, 1)
println(c)



is_inside(a, c)



using Luxor



@pdf begin
    origin(Point(30, 30))
    scale(100, 100)
    fontsize(0.32)
    fontface("Liberation Sans")
    setdash("solid")
    setcolor("black")
    circle(Point(2, 2), 2, :stroke)
    text("a", Point(1, 3))
    setcolor("blue")
    circle(Point(1, 1), 0.5, :stroke)
    text("b", Point(1, 1))
    setcolor("green")
    circle(Point(3, 3), 1, :stroke)
    text("c", Point(3, 3))
end 500 500 "circles_jl.pdf"





struct ReasonableCircle <: Circle
    r::Real
    ReasonableCircle(r) =
        if r >= 0
            new(r)
        else
            @error("It's not reasonable to make a circle with a negative radius.")
        end
end



ReasonableCircle(-12)



ReasonableCircle(12).r









@kwdef struct Ellipse
    axis1::Real = 1
    axis2::Real = 1
end





oval = Ellipse(axis2=2.6)



oval.axis1, oval.axis2





Ellipse(2, 3)



Ellipse(2, axis2=3)
















function safe_divide(a, b)
    if b == 0
        return 0
    else
        return a / b
    end
end



safe_divide(1, 2)



safe_divide(1, 0)





println(typeof(safe_divide(1, 2)))
println(typeof(safe_divide(1, 0)))







@code_warntype safe_divide(1, 2)







function safe_divide2(a, b)
    if b == 0
        return 0.0
    else
        return a / b
    end
end





@code_warntype safe_divide2(1, 2)







function safe_divide_typed(a, b)::Float64
    if b == 0
        return 0.0
    else
        return a / b
    end
end













function leibnz(N)
    s = 0
    for n in 1:N
        s += (-1)^(n + 1) * 1(2n - 1)
    end
end



using Plots;
pyplot();
