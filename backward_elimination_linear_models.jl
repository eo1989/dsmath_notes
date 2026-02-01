# using Symbolics
# @variables x y
# z = x^2 + y
# for whatever reason vim-slime has a hard time sending these w/ the line
# breaks
# A = [x^2 + y 0 2x
#      0       0 2y
#      y^2 + x 0 0]
# using Latexify
# latexify(A)
# using SparseArrays
# spA = sparse(A)
# latexify(A)
# function f(u)
#     [u[1] - u[3], u[1]^2 - u[2], u[3]^2 + u[1]]
# end
# f([x, y, z])
# u = Symbolics.variables()
# params = (;a = 2, b = 1., c = [1, 2, 3])
# function f2(p)
#     a, b, c = p.a, p.b, p.c
#     return a + b
# end
# f2(params)

using StatsModels, RDatasets, DataFrames, GLM, Random
Random.seed!(0)

n = 30
df = dataset("MASS", "cpus")[1:n, :]
df.Freq = map(x -> 10^9 / x, df.CycT)

df = df[:, [:Perf, :MMax, :Cach, :ChMax, :Freq]]
df.Junk1 = rand(n)
df.Junk2 = rand(n)

function stepReg(df, reVar, pThresh)
    predVars = setdiff(propertynames(df), [reVar])
    numVars = length(predVars)
    model = nothing
    while numVars > 0
        fm = term(reVar) ~ term.((1, predVars...))
        model = lm(fm, df)
        pVals = coeftable(model).cols[4][2:end]
        println("Variables: ", predVars)
        println("P-Values", round.(pVals, digits=3))
        pVal, knockout = findmax(pVals)
        pVal < pThresh && break
        println("\tRemoving the variable: ", predVars[knockout], " with p-value =  ", round(pVal, digits=3))
        deleteat!(predVars, knockout)
        numVars = length(predVars)
    end
    model
end

model = stepReg(df, :Perf, 0.05)
println(model)
