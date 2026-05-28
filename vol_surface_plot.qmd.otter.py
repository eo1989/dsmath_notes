

















import dotenv
import pandas as pd
import quantflow.options as qf_opts
from volvisualizer import volatility

keys = dotenv.load_dotenv(dotenv_path="/Users/eo/Dev/.env")
import os



from quantflow.data.fmp import FMP
from quantflow.utils import distributions, plot, transforms



print(dotenv.get_key("../.env", "FINANCIAL_MODELING_PREP_API_KEY"))
FMP_key = dotenv.get_key("../.env", "FINANCIAL_MODELING_PREP_API_KEY")











# tickers = ["OKLO", "AAPL", "LEU", "AMZN", "NKTR"]
tickers = [
    "AAPL",
    "TSLA",
    "AMZN",
    "MSFT",
    "NVDA",
    "GOOGL",
    "META",
    "NFLX",
    "JPM",
    "V",
    "BAC",
    "AMD",
    "PYPL",
    "DIS",
    "T",
    "PFE",
    "COST",
    "INTC",
    "KO",
    "TGT",
    "NKE",
    "SPY",
    "BA",
    "BABA",
    "XOM",
    "WMT",
    "GE",
    "CSCO",
    "VZ",
    "JNJ",
    "CVX",
    "PLTR",
    "SQ",
    "SHOP",
    "SBUX",
    "SOFI",
    "HOOD",
    "RBLX",
    "SNAP",
    "AMD",
    "UBER",
    "FDX",
    "ABBV",
    "ETSY",
    "MRNA",
    "LMT",
    "GM",
    "F",
    "RIVN",
    "LCID",
    "CCL",
    "DAL",
    "UAL",
    "AAL",
    "TSM",
    "SONY",
    "ET",
    "NOK",
    "MRO",
    "COIN",
    "RIVN",
    "SIRI",
    "SOFI",
    "RIOT",
    "CPRX",
    "PYPL",
    "TGT",
    "VWO",
    "SPYG",
    "NOK",
    "ROKU",
    "HOOD",
    "VIAC",
    "ATVI",
    "BIDU",
    "DOCU",
    "ZM",
    "PINS",
    "TLRY",
    "WBA",
    "VIAC",
    "MGM",
    "NFLX",
    "NIO",
    "C",
    "GS",
    "WFC",
    "ADBE",
    "PEP",
    "UNH",
    "CARR",
    "FUBO",
    "HCA",
    "TWTR",
    "BILI",
    "SIRI",
    "VIAC",
    "FUBO",
    "RKT",
]



def grab_tickers(x):
    return [x for x in tickers if x in tickers]


cli = FMP(key=FMP_key)



# prices = await cli.prices("RKT", frequency="1min", from_date = "2026-02-01",
# to_date = "2026-03-10")
prices = await cli.prices("RKT", frequency="")

df = [
    prices.drop(
        columns=[
            d
            for d in prices.columns
            if d
            not in [
                "open",
                "high",
                "low",
                "close",
                "volume",
                "change",
                "date",
                "changePercent",
                "symbol",
            ]
        ]
    ),
    index,
]



import plotly.express as px

plot.candlestick_plot(prices).update_layout(height=500)



df_backup = prices.copy()

df = prices.drop(columns=["symbol", "vwap"])
df_rkt = df.copy()
df_rkt



from quantflow.ta.ohlc import OHLC

# df = OHLC(serie=prices, rogers_satchell_variance=True, parkinson_variance=True)
df_rkt_close = OHLC(df_rkt)
df_rkt_close



async with FMP(key=FMP_key) as cli:
    for v in tickers:
        print(v)
    loader = await cli.quote(v)
