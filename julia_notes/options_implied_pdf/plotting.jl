using Plots

function make_dir_if_not_exists(dir::String)
    if !isdir(dir)
        mkpath(dir)
    end
end

function plot_paritized_prices(paritized, ticker, dir::String)
    plot(
        paritized.strike,
        paritized.price;
        seriestype = :scatter,
        marker = :circle,
        xlabel = "Strike",
        ylabel = "Price",
        title = "$(ticker) Paritized Option Prices",
        legend = false,
    )
    savefig("$(dir)/1_paritzed_plot.png")
end

function plot_iv_smile(paritized_with_iv, ticker, dir::String)
    plot(
        paritized_with_iv.strike,
        paritized_with_iv.iv;
        seriestype = :scatter,
        marker = :circle,
        xlabel = "Strike",
        ylabel = "Implied Vol",
        title = "$(ticker) Implied Volatility Smile",
        legend = false,
    )
    savefig("$(dir)/2_iv_smile.png")
end

function plot_smoothed_iv(smoothed_data, ticker, dir::String)
    plot(
        smoothed_data.strike,
        smoothed_data.iv;
        seriestype = :scatter,
        marker = :circle,
        xlabel = "Strike",
        ylabel = "(Smoothed) Implied Vol",
        title = "$(ticker) Implied Volatility Smile smoothed ",
        legend = false,
    )
    savefig("$(dir)/3_iv_smile_smoothed.png")
end

function plot_smoothed_iv_filtered(smoothed_data_no_nans, ticker, dir::String)
    plot(
        smoothed_data_no_nans.strike,
        smoothed_data_no_nans.iv;
        seriestype = :scatter,
        marker = :circle,
        xlabel = "Strike",
        ylabel = "Implied Vol (smoothed)",
        title = "$(ticker) Implied Volatility Smile smoothed (w/o NaNs)",
    )
    savefig("$(dir)/4_iv_smile_smoothed_filtered.png")
end

function plot_svi_fit(smoothed_data_no_nans, iv_fun, ticker, dir::String)
    K = Float64.(smoothed_data_no_nans.strike)
    iv = Float64.(smoothed_data_no_nans.iv)
    K_dense = range(minimum(K), maximum(K); length = 400)
    iv_dense = iv_fun.(K_dense)
    plot(
        K_dense,
        iv_dense;
        label = "SVI fitted IV",
        linewidth = 2,
        xlabel = "Strike",
        ylabel = "",
    )
end