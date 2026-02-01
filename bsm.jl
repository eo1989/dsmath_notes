using Distributions, DataFrames, PrettyTables, Crayons



N(x) = cdf(Normal(0, 1), x)

function BSM(S, K, T, r, d, σ, cp)
    """
    CP is a call put flag, 1 for call, -1 for put. ignoring it the formula is:
    ℯ^{-d * T} * S * N(d1) - K * ℯ^{-r * T} * N(d2)

    """
    d1 = (log(S / K) + (r - d + σ^2 / 2) * T) / (σ * sqrt(T))
    d2 = d1 - σ * sqrt(T)
    opt = exp(-d * T) * cp * S * N(cp * d1) - cp * K * exp(-r * T) * N(cp * d2)
    delta = cp * exp(-d * T) * N(cp * d1)
    return opt, delta
end

S, K, T, d, r, σ = 100, 100, 1, 0.03, 0.04, 0.3
call = BSM(S, K, T, r, d, σ, 1)
put = BSM(S, K, T, r, d, σ, -1)
df = DataFrame("Call" => call[1], "Delta Call" => call[2], "Put" => put[1], "Delta Put" => put[2])
PrettyTables.pretty_table(
    df,
    border_crayon=Crayons.crayon"blue",
    header_crayon=Crayons.crayon"bold green",
    formatters=ft_printf("%.4f", [1, 2, 3, 4])
)
# returns ATM spot, hence the resulting synthetic forward wouldnt be zero cost. Nonetheless,
# the (carry benefit adjusted) put-call parity, defined as:
#==[[
\begin{equation}
    p + S * ℯ^{-d * T} == c + ℯ^{-r * T} * K
\end{equation}
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
    "Put Black76" => put_black
)
PrettyTables.pretty_table(
    df,
    border_crayon=Crayons.crayon"blue",
    header_crayon=Crayons.crayon"bold green",
    formatters=ft_printf("%.4f", [1, 2, 3, 4])
)
