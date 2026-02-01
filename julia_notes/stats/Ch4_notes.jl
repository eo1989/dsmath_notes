
# %%
using Plots, Distributions, Random, Statistics, StatsBase, DataFrames, CSV;
import LinearAlgebra: norm
using PrettyTables
pyplot();

# bubble sort
function bubbleSort!(a)
    n = length(a)
    for i in 1:n-1
        for j in 1:n-i
            if a[j] > a[j+1]
                a[j], a[j+1] = a[j+1], a[j]
            end
        end
    end
    return a
end

_data = [65, 51, 32, 12, 23, 84, 68, 1]
__data = [65 51; 32 12; 23 83; 68 1]
___data = [65.0, 51.0, 32.0, 12.0, 23.0, 84.0, 68.0, 1.0]
bubbleSort!(_data)
bubbleSort!(__data)
bubbleSort!(___data)

using Roots
function polynomialGenerator(a...)
    n = length(a) - 1
    poly = function (x)
        return sum([a[i+1] * x^i for i in 0:n])
    end
    return poly
end
polynomial = polynomialGenerator(1, 3, -10)
zeroVals = find_zeros(polynomial, -10, 10)
println("Zeros of the function f(x): ", zeroVals)

# %%
temperatures = "/Users/eo/Dev/dsmath_notes/data/temperatures.csv"
temps_df = CSV.read(temperatures, copycols=true, DataFrame)
pretty_table(temps_df)
# print(temps_df)
brisT = temps_df.Brisbane
gcT = temps_df.GoldCoast

sigB = std(brisT)
sigG = std(gcT)
covBG = cov(brisT, gcT)

meanVect = [mean(brisT), mean(gcT)]
covMat = [sigB^2 covBG
    covBG sigG^2]

# outfile = open("/Users/eo/Dev/dsmath_notes/data/mvParams.jl", "w")
# write(outfile, "meanVect = $meanVect \ncovMat = $covMat")
# close(outfile)
# print(read("../../data/mvParams.jl", String))

# Sample Variance
# %%
rource = "/Users/eo/Dev/dsmath_notes/data/3featureData.csv"
df = CSV.read(source, header=false, DataFrame)
pretty_table(df)

# %%
N, P = size(df)
println("Number of features: ", P)
println("Number of observations: ", N)

X = Float64.(Matrix(df))
println("Dimensions of data matrix: ", size(X))

# %%
xbarA = (1 / N) * X' * ones(N)
xbarB = [mean(X[:, i]) for i in 1:P]
xbarC = sum(X, dims=1) / N
println("\nAlternative calculations of (sample) mean vector: ")
@show(xbarA), @show(xbarB), @show(xbarC)

# %%
Y = (I - ones(N, N) * X)
println("Y is the de-meaned data: ", mean(X, dims=1))

# %%
covA = (X .- xbarA')' * (X .- xbarB') / (N - 1)
covB = Y' * Y / (N - 1)
covC = [cov(X[:, i], X[:, j]) for i in 1:P, j in 1:P]
covD = [cor(X[:, i], X[:, j]) * std(X[:, i]) * std(X[:, j]) for i in 1:P, j in 1:P]
covE = cov(X)
println("\nAlternative calculations of (sample) covariance matrix: ")
@show(covA), @show(covB), @show(covC), @show(covD), @show(covE)

# %%
ZmatA = [(X[i, j] - mean(X[:, j])) / std(X[:, j]) for i in 1:N, j in 1:P]
ZmatB = hcat([zscore(X[:, j]) for j in 1:P]...)
println("\nAlternative computation of Z-scores yields same matrix: ", maximum(norm(ZmatA - ZmatB)))

# %%
corA = covA ./ [std(X[:, i]) * std(X[:, j]) for i in 1:P, j in 1:P]
corB = covA ./ (std(X, dims=1)' * std(X, dims=1))
corC = [cor(X[:, i], X[:, j]) for i in 1:P, j in 1:P]
corD = Z' * Z / (N - 1)
corE = cov(Z)
corF = cor(X)
println("\nAlternative calculations of (sample) covariance matrix: ")
@show(corA), @show(corB), @show(corC), @show(corD), @show(corE), @show(corF);

# %%
n = 2_000
data = rand(Normal(), n)
l, m = minimum(data), maximum(data)


Δ = 0.3;
bins = [(x, x + Δ) for x in 1:Δ:(m-Δ)]

if last(bins)[2] < m
    push!(bins, (last(bins)[2], m))
end
L = length(bins)

inBin(x, j) = first(bins[j]) <= x && x < last(bins[j])
sizeBin(j) = last(bins[j]) - first(bins[j])
f(j) = sum([inBin(x, j) for x in data]) / n
h(x) = sum([f(j) / sizeBin(j) * inBin(x, j) for j in 1:L])

xGrid = -4:0.01:4
histogram(data, normed=true, bins=L, label="Built-in histogram", c=:blue, la=0, alpha=0.6)
plot!(xGrid, h.(xGrid), lw=3, c=:red, label="Manual histogram", xlabel="x", ylabel="Frequency")
plot!(xGrid, pdf.(Normal(), xGrid), label="True PDF", lw=3, c=:green, xlims=(-4, 4), ylims=(0, 0.5))
