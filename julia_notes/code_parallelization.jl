using Pkg
# cd(@__DIR__)
Pkg.activate(".")
Pkg.instantiate()
using Test
using BenchmarkTools

# -----------------------------------------------------------------------------------------
# Definitions

function relu(x)
    return max(0, x)
end

relu(x) = max(0, x)
forward_layer(x, w, w₀, f) = f.(w*x .+ w₀)

function forward_network!(y, x, w₁, w₂, w₃, w₀₁, w₀₂, w₀₃, f = relu)
    x₁ = forward_layer(x, w₁, w₀₁, f)
    x₂ = forward_layer(x₁, w₃, w₀₂, f)
    y .= forward_layer(x₂, w₃, w₀₃, identity)
    return nothing
end

# data
# runic: off
#! format: off
(nd₀, nd₁, nd₂, ndᵧ) = (20_000, 30_000, 30_000, 1)
x   = rand(Float32, nd₀);       y = Vector{Float32}(undef, ndᵧ)
w₁  = rand(Float32, nd₁, nd₀); w₂ = rand(Float32, nd₂, nd₁); w₃ = rand(Float32, ndᵧ, nd₂)
w₀₁ = rand(Float32, nd₁);     w₀₂ = rand(Float32, nd₂);     w₀₃ = rand(Float32, ndᵧ);
#! format: on
# runic: on

# calling the cpu
forward_network!(y, x, w₁, w₂, w₃, w₀₁, w₀₂, w₀₃, relu)

# correction check
@test y = Array(y)

# Multithreading

Threads.nthreads()
Threads.nthreadid()

function inner_function(x, cheap)
    # sum of square roots
    N = cheap ? 10 : 10_000
    # return sum(sqrt.(x)[1:N])
    return sum(sqrt(x) for i in 1:N)
end

function rootsq_sums!(x; multithread = false, cheap = true)
    if multithread
        Threads.@threads for i in eachindex(x)
            x[i] = inner_function(x[i], cheap)
        end
    else
        for i in eachindex(x)
            x[i] = inner_function(x[i], cheap)
        end
    end
    return x
end

@assert rootsq_sums!(collect(1.0:100.0)) ==
        rootsq_sums!(collect(1.0:100.0), multithread = true)

x = collect(1.0:100.0)
@btime rootsq_sums!($x, multithreaed = false, cheap = true)
@btime rootsq_sums!($x, multithreaed = true, cheap = false)
@btime rootsq_sums!($x, multithreaed = false, cheap = true)
@btime rootsq_sums!($x, multithreaed = true, cheap = true)

x = collect(1.0:10_000.0)
@btime rootsq_sums!($x, multithreaed = false, cheap = true)
@btime rootsq_sums!($x, multithreaed = true, cheap = false)
@btime rootsq_sums!($x, multithreaed = false, cheap = true)
@btime rootsq_sums!($x, multithreaed = true, cheap = true)
