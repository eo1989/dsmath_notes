using Pkg
# cd(@__DIR__)
Pkg.activate(".")
Pkg.instantiate()
using Test

# ----------------------------------------------------------------------------------
# Symbols & Expressions

@test :foo10 == Symbol("fool10")

a = Symbol("foo", 10)
string(a)

expr = Meta.parse("b = -(a + 1) # This is a comment");
typeof(expr)
dump(expr)

a = 1;
function foo()
    local a = 2
    expr = :(α + 1)
    return a + 1, eval(expr)
end
foo()

a = 1
expr1 = Meta.parse("$a + b + 3")
expr2 = :($a + b + 3)               # equiv to expr1
expr3 = quote
    $a + b + 3
end        # equiv to expr1
expr4 = Expr(:call, :+, a, :b, 3)   # equiv to expr1
expr = Meta.parse("3 + 2")
eval(expr)
# eval(expr1)  # this returns an error because b isnt defined in the current scope
b = 10
eval(expr1)  # 14

a = 100
eval(expr1)  # still 14

b = 100
eval(expr1)  # 104

a = 1
function foo()
    local a = 2
    expr = :(a + 1)
    return a + 1, eval(expr)
end
foo()

# ----------------------------------------------------------------------------------
# MACROS

macro customLoop(controlExpr, workExpr)
    return quote
        for i in $controlExpr
            $workExpr
        end
    end
end
a = 5

@customLoop 1:4 println(i)
@customLoop 1:a println(i)
@customLoop 1:a if i > 3
    println(i)
end
@customLoop ["apple", "orange", "banana"] prinln(i)
@customLoop ["apple", "orange", "banana"] begin
    print("i: ");
    println(i)
end
@macroexpand @customLoop 1:4 println(i)

# ----------------------------------------------------------------------------------
# String macro

macro print8_str(mystr)
    limits = collect(1:8:length(mystr))
    for (i, j) in enumerate(limits)
        st = j
        en = i == length(limits) ? length(mystr) : j + 7
        println(mystr[st:en])
    end
end
# print8"123456789012345678"
print8"123456789012345678"
