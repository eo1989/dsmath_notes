using DataFrames, Dates

include("bs.jl")

function get_τ(expiry_dt::String)
    return Float64((Date(expiry_dt) - today()).value) / 365.0
end

function paritize(
    spot::Float64,
    call_df::DataFrame,
    put_df::DataFrame,
    τ::Float64,
    r::Float64,
)
    calls_otm = filter(:InTheMoney => ==(false), call_df)
    puts_otm = filter(:InTheMoney => ==(false), put_df)

    puts_otm.synth_call_price = puts_otm.mid .+ spot .- puts_otm.strike * exp(-r * τ)

    synth_calls = copy(puts_otm)
    synth_calls.price = synth_calls.synth_call_price
    calls_otm.price = calls_otm.mid

    # call_price_vs_strike = vcat(calls_otm[:, [:strike, :price]], synth_calls[:, [:strike, :price]])
    call_price_vs_strike = calls_otm[:, [:strike, :price]]
    put_price_vs_strike = synth_calls[:, [:strike, :price]]

    paritized_data = vcat(call_price_vs_strike, put_price_vs_strike)
    # sort!(paritized_data, :strike)
    # return paritized_data

    return sort!(paritized_data, :strike)
    # "Returns the paritized call and put dataframes, which are the same except for the mid price. The mid price is adjusted to be the price of a forward contract, which is what we need for the BS model."
    # call_df.parity_mid = call_df.mid .- spot * exp(-r * τ) .+ call_df.strike * exp(-r * τ)
    # put_df.parity_mid = put_df.mid .- spot * exp(-r * τ) .+ put_df.strike * exp(-r * τ)
    # return call_df, put_df

end

function add_IV_col(paritized::DataFrame, spot::Float64, r::Float64, τ::Float64)
    "Adds an IV column to the paritized dataframe using Newtons method."

    paritized.iv = Vector{Float64}(undef, nrow(paritized))

    for (i, row) in enumerate(eachrow(paritized))
        # K = row.strike
        # market_price = row.price
        # bs = BlackScholesMerton(spot, K, τ, 0.0, r, 0.2) # initial guess for σ is 20%
        # paritized.iv[i] = newtons(bs, Call, market_price)

        K = Float64(row.strike)
        mkt = Float64(row.price)
        # logs = i % 50 == 0 ? "Calculating IV for strike = $(K), market price = $(mkt)" : ""
        logs = i % 50 == 0

        bs = BlackScholesMerton(spot, K, τ, 0.0, r, 0.2) # initial guess for σ is 20%

        paritized.iv[i] = try
            newtons(bs, Call, mkt; tol = 1e-8, max_iter = 200, show = logs)
        catch
            NaN
        end
        return paritized
    end
end

function gaussian_smooth(paritized_with_iv::DataFrame, kernel_size::Int)
    N = nrow(paritized_with_iv)

    strikes = paritized_with_iv.strike
    vals = paritized_with_iv.iv

    smoothed = similar(vals)

    for i in 1:N
        j_min = max(1, i - kernel_size)
        j_max = min(N, i + kernel_size)

        weights_sum = 0.0
        val_sum = 0.0
        for j in j_min:j_max
            w = exp(-(i - j)^2 / (2 * kernel_size^2))
            weights_sum += w
            val_sum += w * vals[j]
        end

        smoothed[i] = val_sum / weights_sum
    end
    return DataFrame(;
        strike = strikes,
        iv = smoothed,
    )
end

function remove_nans(data::DataFrame)
    return filter(row -> isfinite(row.iv), data)
end

function fit_iv_spline(smoothed_data::DataFrame, s = 1e-4)
    K = Float64.(smoothed_data.strike)
    iv = Float64.(smoothed_data.iv)
    spl = Spline1D(K, iv; k = 3, s = s)
    return spl
end

function reprice(paritized::DataFrame, spot::Float64, r::Float64, τ::Float64, fit_fn)
    prices = Vector{Float64}(undef, nrow(paritized))

    for (i, row) in enumerate(eachrow(paritized))
        K = Float64(row.strike)
        σ = fit_fn(K)
        bs = BlackScholesMerton(spot, K, τ, 0.0, r, σ)
        prices[i] = bs(Call)
    end

    return DataFrame(;
        strike = paritized.strike,
        price = prices,
    )
end

function Breeden_Litzenberger(
    K::Float64,
    spot::Float64,
    iv_fun::Function,
    r::Float64,
    τ::Float64,
    h::Float64 = 0.001,
)
    "Using the Breeden_Litzenberger forrmula, this computes the risk-neutral PDF at strike k given a function iv_fun:σ→price
    r is the risk-free rate, τ is time to expiry in years."
    C(Kx) = BlackScholesMerton(spot, Kx, τ, 0.0, r, iv_fun(Kx))(Call)

    if K <= h
        d2C = (C(K + 2h) - 2C(K + h) + C(K)) / (h^2)
    else
        d2C = (C(K + h) - 2C(K) + C(K - h)) / (h^2)
    end
end

function p_at_or_above(K::Float64, spot::Float64, iv_fun::Function, r::Float64, τ::Float64)
    "Computes the risk-neutral probability that the underlying will be above strike K at expiry using the Breeden-Litzenberger formula.
    This is done by taking the cdf at K, and subtracting it from 1."
    return 1.0 - p_below(K, spot, iv_fun, r, τ)
end

function p_below(K::Float64, spot::Float64, iv_fun::Function, r::Float64, τ::Float64)
    "Computes the risk-neutral probability that the underlying will be below strike K at expiry using the Breeden-Litzenberger formula.
  This is done by integrating the risk-neutral PDF from 0 to K. using the trapezoidel rule.
  This is the cdf at K."
    integrand(k) = Breeden_Litzenberger(k, spot, iv_fun, r, τ)

    lower_limit = 1.0
    num_points = 10_000
    dk = (K - lower_limit) / num_points

    integral = 0.0
    for i in 0:(num_points - 1)
        k1 = lower_limit + i * dk
        k2 = lower_limit + (i + 1) * dk
        integral += 0.5 * (integral(k1) + integral(k2)) * dk
    end
    return integral
end

export OptionsImpliedPDF