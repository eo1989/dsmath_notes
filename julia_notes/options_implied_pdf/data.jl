using DataFrames, PythonCall

yf = pyimport("yfinance")
pd = pyimport("pandas")

function get_option_prices(ticker::String, expiry_date::String)
    "Returns two dataframes. One with calls, one with puts, for a given ticker and expiry date."

    stock = yf.Ticker(ticker)

    @assert length(stock.options) > 0 "No options data found for the given ticker: $(ticker). Check that the ticker is correct!"
    @assert expiry_date in stock.options "Expiry date: $(expiry_date) not found in given ticker: $(ticker). Possible dates are $(stock.options)."

    opt_chain = stock.option_chain(expiry_date)

    call_df = DataFrame(PyTable(opt_chain.calls))

    put_df = DataFrame(PyTable(opt_chain.puts))

    call_df.mid = (call_df.ask .+ call_df.bid) ./ 2

    put_df.mid = (put_df.ask .+ put_df.bid) ./ 2

    nq, n = quote_health(call_df)
    if nq == 0
        @warn "No live bid/ask quotes from yahoo for calls. Falling back to lastPrice only; results may be unreliable."
        call_df.mid = call_df.lastPrice .+ 0.0
    end

    nq, n = quote_health(put_df)
    if nq == 0
        @warn "No live bid/ask quotes from yahoo for puts. Falling back to lastPrice only; results may be unreliable."
        put_df.mid = put_df.lastPrice .+ 0.0
    end

    return call_df, put_df
end

function quote_health(df::DataFrame)
    q = (df.bid .> 0) .& (df.ask .> 0)
    return count(q), nrow(df)
end

function spot_price(ticker::String)
    "Returns the current spot price of the given ticker."
    stock = yf.Ticker(ticker)
    spot = pyconvert(Float64, stock.fast_info["lastPrice"])
    return spot
end

"""
    get_closest_expiry(ticker::String)

Returns the closest expiry data string for the given ticker.
"""
function get_closest_expiry(ticker::String)
    stock = yf.Ticker(ticker)
    @assert length(stock.options) > 0 "No options data found for the given ticker: $(ticker). Check that the ticker is correct!"
    closest_expiry = pyconvert(String, stock.options[1])
    return closest_expiry
end
export get_option_prices