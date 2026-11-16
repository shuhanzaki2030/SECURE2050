# Signal Bot launcher: serves trading-signal-bot.html on localhost and relays
# Revolut X *public* market-data requests, Yahoo Finance stock charts and Nasdaq stock quotes
# (the browser can't call either directly).
# No API key is used or needed. Stop with Ctrl+C or by closing the window.
param([int]$Port = 8765, [switch]$NoBrowser)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Net.Http
$client = New-Object System.Net.Http.HttpClient
$client.Timeout = [TimeSpan]::FromSeconds(15)
$client.DefaultRequestHeaders.UserAgent.ParseAdd('Mozilla/5.0')
$client.DefaultRequestHeaders.Accept.ParseAdd('application/json')
$page = Join-Path $PSScriptRoot 'trading-signal-bot.html'

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Host "Signal Bot running at http://localhost:$Port  (Ctrl+C to stop)"
if (-not $NoBrowser) { Start-Process "http://localhost:$Port/" }

function Send($ctx, [int]$status, [string]$type, [byte[]]$bytes) {
  $ctx.Response.StatusCode = $status
  $ctx.Response.ContentType = $type
  $ctx.Response.Headers['Cache-Control'] = 'no-store'
  $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  $ctx.Response.Close()
}

while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  try {
    $path = $ctx.Request.Url.PathAndQuery
    if ($path -match '^/revx/(1\.0|2\.0)/public/[A-Za-z0-9\-/_]+(\?[A-Za-z0-9\-_=&,.%]*)?$') {
      # only public Revolut X endpoints are relayed, always to the fixed Revolut host
      $resp = $client.GetAsync('https://revx.revolut.com/api/' + $path.Substring(6)).Result
      $body = $resp.Content.ReadAsByteArrayAsync().Result
      Send $ctx ([int]$resp.StatusCode) 'application/json' $body
    } elseif ($path -match '^/yf/v8/finance/chart/[A-Za-z0-9.\-\^=%]+\?[A-Za-z0-9\-_=&,.%]*$') {
      # Yahoo Finance chart data for stocks (no key); only the chart endpoint is relayed
      $resp = $client.GetAsync('https://query1.finance.yahoo.com' + $path.Substring(3)).Result
      $body = $resp.Content.ReadAsByteArrayAsync().Result
      Send $ctx ([int]$resp.StatusCode) 'application/json' $body
    } elseif ($path -match '^/nq/api/quote/[A-Za-z0-9.\-]+/info\?assetclass=(stocks|etf)$') {
      # Nasdaq real-time quote (bid/ask/last) for stocks; only this endpoint is relayed
      $resp = $client.GetAsync('https://api.nasdaq.com' + $path.Substring(3)).Result
      $body = $resp.Content.ReadAsByteArrayAsync().Result
      Send $ctx ([int]$resp.StatusCode) 'application/json' $body
    } elseif ($path -eq '/' -or $path.StartsWith('/?') -or $path -eq '/trading-signal-bot.html') {
      Send $ctx 200 'text/html; charset=utf-8' ([IO.File]::ReadAllBytes($page))
    } else {
      Send $ctx 404 'text/plain' ([Text.Encoding]::UTF8.GetBytes('Not found'))
    }
  } catch {
    try { Send $ctx 502 'text/plain' ([Text.Encoding]::UTF8.GetBytes($_.Exception.Message)) } catch {}
  }
}
