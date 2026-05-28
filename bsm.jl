using Crayons, DataFrames, PrettyTables
using Distributions: cdf, Normal

N(x) = cdf(Normal(0, 1), x)

"""
CP is a call put flag, 1 for call, -1 for put. ignoring it the formula is:
ℯ^{-d * T} * S * N(d1) - K * ℯ^{-r * T} * N(d2)
"""
function BSM(S, K, T, r, d, σ, cp)
    d1 = (log(S / K) + (r - d + σ^2 / 2) * T) / (σ * sqrt(T))
    d2 = d1 - σ * sqrt(T)
    opt = exp(-d * T) * cp * S * N(cp * d1) - cp * K * exp(-r * T) * N(cp * d2)
    delta = cp * exp(-d * T) * N(cp * d1)
    return opt, delta
end

# Apple at 1400 on 7/20/2026
# 325.0, iv 32.48%, 4dte (7/24/26) iv 340C 32.11%, rfr 0.0325, divie = 0.27,
# 4/252 ~0.0158730

S, K, T, r, d, σ = 325.0, 340, 0.01587, 0.0325, 0.27, 0.3211
call = BSM(S, K, T, r, d, σ, 1)
put = BSM(S, K, T, r, d, σ, -1)

df = DataFrame(
    "Call" => call[1],
    "Delta Call" => call[2],
    "Put" => put[1],
    "Delta Put" => put[2],
)

style = TextTableStyle(; first_line_column_label = crayon"green bold");

pretty_table(
    df;
    style,
    formatters = [fmt__printf("%.4f", [1, 2, 3, 4])],
    # border_crayon = Crayons.crayon"blue",
    # header_crayon = Crayons.crayon"bold green",
    # backend = "markdown",
)

# returns ATM spot, hence the resulting synthetic forward wouldnt be zero cost. Nonetheless,
# the (carry benefit adjusted) put-call parity, defined as:

#==[[
```math
\begin{equation}
    p + S * ℯ^{-d * T} == c + ℯ^{-r * T} * K
\end{equation}
```
]]==#

# println("PC Parity computed Put value = $(round((call + exp(-r * T) * K - S * exp(-d * T)), digits = 4))")

println("Put price according to BSM = $(round(put[1], digits = 4))")

function Black76(F, K, t, r, σ, cp)
    d1 = (log(F / K) + 0.5 * σ^2 * t) / σ * sqrt(t)
    d2 = d1 - σ * sqrt(t)
    opt = cp * exp(-r * t) * (F * N(cp * d1) - K * N(cp * d2))
    return opt
end

k = S * exp((r - d) * T)
f = k
call = BSM(S, K, T, r, d, σ, 1)
put = BSM(S, K, T, r, d, σ, -1)
call_black = Black76(f, K, T, r, σ, 1)
put_black = Black76(f, K, T, r, σ, -1)
df = DataFrame(
    "Call" => call[1],
    "Delta Call" => call[2],
    "Put" => put[1],
    "Delta Put" => put[2],
    "Forward" => k,
    "Call Black76" => call_black,
    "Put Black76" => put_black,
)

pretty_table(
    df;
    style,
    formatters = [fmt__printf("%.4f", [1, 2, 3, 4])],
    # border_crayon = crayon"blue",
    # header_crayon = crayon"bold green",
)
