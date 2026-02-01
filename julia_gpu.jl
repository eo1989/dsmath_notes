#%%
using BenchmarkTools
using Statistics

BenchmarkTools.DEFAULT_PARAMETERS.seconds = 15.0

using CUDA

N = 3_000
A = rand(N, N)

# use `using` not `import` to bring the macros into scope.
@benchmark $A * $A
# memory estimate: 68.67 MiB, allocs estimate: 3. median time: 336.9 ms, μ + σ: 341.05 ⨦ 17.8 ms

# has_cuda() || error("CUDA not available")
# has_cuda_gpu() || error("No CUDA GPU found")
# No CUDA gpu on this mbpa :(
# A_gpu = CuArray(A) # first compilation will take a minute

let
    @show a = (0.1 + 0.2) + 0.3
    @show b = 0.1 + (0.2 + 0.3)
    @show a - b
end
# a-b = 1.1102230246251565e-16

mean(abs.(A * A - Array(A * A)))
# 0.0

using Plots, Images, FileIO

begin
    url = "https://raw.githubusercontent.com/mitmath/JuliaComputation/756ee73e14dd4e27bb9a1ac2ca7c415d241366b4/notebooks/20220422_philip.jpg"
    bigphil = load(download(url))
    smallphil = imresize(bigphil, (400, 300))
    pic = smallphil
end

# time to transform that corgi
begin
    translate(α, β) = ((x, y), ) -> (x + α, y + β)
    scale(α) = ((x, y), ) -> [α * x, α * y]
    swap((x, y)) = [y, x]
    flipy((x, y)) = [x, -y]
    rotate(θ) = ((x, y), ) -> [cos(θ)*x + sin(θ)*y, -sin(θ)*x + cos(θ)*y]
    hyperbolic_rotate(θ) = ((x, y), )
end
