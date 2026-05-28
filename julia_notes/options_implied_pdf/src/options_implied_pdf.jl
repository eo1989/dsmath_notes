module options_implied_pdf
include(joinpath(@__DIR__, "data.jl"))
# include(joinpath(@__DIR__, "bs.jl"))
include(joinpath(@__DIR__, "functions.jl"))
include(joinpath(@__DIR__, "svi.jl"))
include(joinpath(@__DIR__, "plotting.jl"))

using DataFrames, Dates, Distributions, Plots, PythonCall

#top level functions that people will have access to.

"""
    prob_below(ticker::String, strike_price::Float64, expiry::String, savedir::Union{String, Nothing}=nothing)

Returns the probability of the underlying asset being below the strike price at expiry. (sampled from risk-neutral pdf)

setting savedir to a directory path will save all the plots generated in that directory under subfolders for ticker and expiry.
"""

function prob_below(
    ticker::String,
    strike_price::Float64,
    expiry::String,
    savedir::Union{String,Nothing} = nothing,
)
    spot = get_spot_price(ticker)
    call_df, put_df = get_option_prices(ticker, expiry)
    r == rate = 0.01
    τ = get_τ(expiry)
    F = spot * exp(r * τ)

    paritized = paritize(spot, call_df, put_df, τ, r)
    paritized_with_iv = add_IV_col(paritized, spot, r, τ)
    smoothed_data = gaussian_smooth(paritized_with_iv, 5)
    smoothed_data_no_nans = remove_nans(smoothed_data)

    fit, iv_fun = fit_svi_smile(
        Float64.(smoothed_data_no_nans.strike),
        Float64.(smoothed_data_no_nans.iv),
        F, τ, 1e-4,
    )

    repriced_paritized = reprice(paritized, spot, r, τ, iv_fun)

    probability_below = p_below(
        strike_price,
        spot,
        iv_fun,
        r,
        τ,
    )

    # logic for plotting here:
    if savedir !== nothing
        dir = "$(savedir)/$(ticker)/$(expiry)"
        make_dir_if_not_exists(dir)
        plot_paritized_prices(paritized, ticker, dir)
        plot_iv_smile(paritized_with_iv, ticker, dir)
        plot_smoothed_iv(smoothed_data_no_nans, ticker, dir)
        plot_smoothed_iv_filtered(smoothed_data_no_nans, ticker, dir)
        plot_svi_fit(smoothed_data_no_nans, iv_fun, ticker, dir)
        plot_repriced_prices(repriced_paritized, ticker, dir)
        plot_pdf_numerical(repriced_paritized, spot, iv_fun, r, τ, ticker, expiry, dir)
    end

    return probability_below
end

"""
    prob_at_or_above(ticker::String, strike_price::Float64, expiry::String, savedir::Union{String, Nothing} = nothing)
    Returns the probability of the underlying asset being at or above the strike price at expiry. (sampled from risk-neutral pdf)

    setting savedir to a directory path will save all the plots generated in that directory under subfolders for ticker and expiry.
"""
function prob_or_at_above(
    ticker::String,
    strike_price::Float64,
    expiry::String,
    savedir::Union{String,Nothing} = nothing,
)
    return 1 - prob_below(ticker, strike_price, expiry, savedir)
end

export prob_at_or_above
export prob_below
export get_closest_expiry

end