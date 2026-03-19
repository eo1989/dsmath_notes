using LaTeXStrings, LinearAlgebra, Plots

# input values
σ² = 24.4 # variance of d(n)
𝐩 = [2 4.5] # cross-correlation between 𝐱(n) and d(n)
𝐰ₒ = [2 4.5] # Wiener solution
rₓ0, rₓ1 = 1, 0
𝐑ₓ = [rₓ0 rₓ1;
    rₓ1 rₓ0]

# w₀ = range(start=0, stop=10, length=100)
# w₁ = range(start=0, stop=10, length=100)
# 𝐰 = [w₀, w₁] # coefficient vector

J(w₀, w₁) = σ² - 2𝐩 ⋅ [w₀; w₁] + [w₀; w₁]' * 𝐑ₓ * [w₀; w₁]

surface(-15:0.1:15, -10:0.1:20, J; camera = (60, 40, 0), zlabel = L"J(\mathbf{w})")
scatter!(
    [𝐰ₒ[1]],
    [𝐰ₒ[2]],
    [J(𝐰ₒ[1], 𝐰ₒ[2])];
    markershape = :circle,
    color = :red,
    markersize = 6,
    label = "Wiener solution",
)

savefig("cost_function.png")
