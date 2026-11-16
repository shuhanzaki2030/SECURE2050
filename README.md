# Signal Bot

A live market dashboard for Windows that analyses crypto, stocks and forex with technical indicators
and shows broker-style **Sell / Buy** prices.

> ⚠️ Educational project. The signals come from simple technical indicators and are often wrong.
> This is not financial advice, and the tool never places orders.

## Features

- **Live prices, no API keys**
  - Crypto (BTC, ETH, …): Revolut X public market data, or Binance (every trade streamed)
  - US stocks (AAPL, NVDA, …): Nasdaq bid/ask + Yahoo Finance candles, including pre-market and after-hours
  - Forex (EUR/USD, GBP/USD, …): Yahoo Finance live rate with an estimated 1-pip spread
- **Sell / Buy (bid / ask) prices** and spread for every symbol, like a broker app
- **Signals**: SMA 20/50, RSI, MACD and Bollinger Bands combined into Strong Buy / Buy / Hold / Sell / Strong Sell,
  with an entry, stop-loss and take-profit (based on ATR)
- **Chart** with price, moving averages, Bollinger Bands and RSI
- **Recent trades** list and a live "price moves per minute" counter
- **Bot feed and desktop alerts** when a signal changes
- Prices in **£ / $ / €**, timeframes 15 min to 1 day

## Run it (Windows)

1. Download this repository (green **Code** button → **Download ZIP**) and unzip it.
2. Double-click **`Start Signal Bot.cmd`**.
3. Your browser opens **http://localhost:8765**. Keep the black window open while you use it; close it to stop.

No installation is needed. It uses Windows PowerShell, which every Windows PC has.

Why a launcher? Revolut, Yahoo and Nasdaq don't let web pages call them directly, so
`start-signal-bot.ps1` runs a tiny local web server that serves the page and relays those public
market-data requests. It only listens on your own PC (`localhost`) and only relays the specific public endpoints.

## Files

| File | What it is |
|---|---|
| `trading-signal-bot.html` | The whole app (one page: data, indicators, chart, alerts) |
| `start-signal-bot.ps1` | Local launcher and data relay |
| `Start Signal Bot.cmd` | Double-click shortcut that runs the launcher |

## Notes

- Your watchlist and settings are saved in your browser on your PC.
- Data sources are free and partly unofficial (Yahoo Finance, Nasdaq quote data); they may change or rate-limit without notice.
