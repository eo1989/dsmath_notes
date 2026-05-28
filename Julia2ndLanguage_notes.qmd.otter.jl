























# will be used later
using Statistics

sales = [
    ("hawaiian", 'S', 10.5),
    ("sicilian", 'M', 12.25),
    ("hawaiian", 'L', 16.5),
    ("bbq chicken", 'L', 20.75),
    ("bbq chicken", 'M', 16.75),
]

name(pizza) = pizza[1]
portion(pizza) = pizza[2]
price(pizza) = pizza[3]

issmall(pizza) = portion(pizza) == 'S'
islarge(pizza) = portion(pizza) == 'L'
isbbq(pizza) = name(pizza) == "bbq chicken"



function print_sin_table(increment, max_angle)
    # println("  angle |   sin(angle)")
    # println("------- | -------------")
    for angle in 0:increment:max_angle
        @printf("%7d | %13.6f\n", angle, sin(deg2rad(angle)))
    end
    angle = 0
    while angle <= max_angle
        rad = deg2rad(angle)
        x = sin(rad)
        println(x)
        # angle = angle + increment
        angle += increment
    end
end




function print_trig_table(inc, maxangle)
    print("│ ")
    printstyled($"\theta$ ", color = :cyan)
    print(" │ ")
    printstyled(rpad("cos", n), color = :cyan)
    print(" │ ")
    printstyled(rpad("sin", n), color = :cyan)
    println(" │")
    angle = 0
    while angle <= maxangle
        rad = deg2rad(angle)
        cosx = format(cos(rad))
        sinx = format(sin(rad))
        print("│ ")
        print(lpad(angle, 3), " │ ", lpad(cosx, 6), " │ ", lpad(sinx, 6))
        println(" │")
        angle += inc
    end
end



n = length("-0.966")





degs = [0, 15, 30, 45, 60];
rads = map(deg2rad, degs)
_rads = map(deg2rad, 0:15:90)
map(sin, _rads)






ys = map(f, xs)






map(deg2rad, 0:15:90)





map(sin, map(deg2rad, 0:15:90))




map(x -> sin(deg2rad(x)), 0:15:90)









result = zeros(Float64, length(0:15:90))
map!(deg2rad, result, 0:15:90)
map!(sin, result, result)  # The input and destination array must have equal length!






degsin(deg) = sin(deg2rad(deg))
map(degsin, 0:15:90)



# as a multiline function:
function degsin(deg)
    sin(deg2rad(deg))
end
map(degsin, 0:15:90)



# knock off version of `map` called `transform`.
function transform(fun, xs)
    ys = []
    for x in xs
        push!(ys, fun(x))
    end
    ys
end



# quick tutorial on Chars
x = Int8(65)



ch = Char(65)



ch = Char(66)



'A'



Int8('A')



'A' + 'B'



'A' + 4



chars = ['H', 'E', 'L', 'L']



collect(chars)



join(chars)



collect("HELL")
