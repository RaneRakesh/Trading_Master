import datetime
from fastapi import APIRouter, Query, HTTPException
from typing import List
from app.models.schemas import MarketStatusResponse, ChartDataResponse, Candle
from app.services.market_data_service import market_service

router = APIRouter(prefix="/api/v1/market", tags=["market"])

@router.get("/status", response_model=MarketStatusResponse)
def get_market_status():
    """Returns general market regime and benchmark indices status."""
    now = datetime.datetime.now()
    return MarketStatusResponse(
        nse_status="OPEN" if 9 <= now.hour < 16 else "CLOSED",
        nifty50_price=25415.80,
        nifty50_change=124.50,
        nifty50_percent=0.49,
        banknifty_price=53820.40,
        banknifty_change=260.10,
        banknifty_percent=0.48,
        regime="Bullish + Moderate Volatility",
        regime_description="Benchmark index trading comfortably above 20 & 50 EMAs with healthy sector participation.",
        timestamp=now.strftime("%Y-%m-%d %H:%M:%S")
    )

@router.get("/{symbol}/chart", response_model=ChartDataResponse)
def get_chart_data(symbol: str, timeframe: str = Query("1M", pattern="^(1D|5D|1M|6M|1Y)$")):
    """Returns OHLCV candlesticks for the specified timeframe."""
    try:
        df = market_service.fetch_ohlcv(symbol, timeframe)
        candles = [
            Candle(
                timestamp=str(row["timestamp"]),
                open=round(float(row["open"]), 2),
                high=round(float(row["high"]), 2),
                low=round(float(row["low"]), 2),
                close=round(float(row["close"]), 2),
                volume=int(row["volume"])
            )
            for _, row in df.iterrows()
        ]
        return ChartDataResponse(
            symbol=symbol.upper(),
            timeframe=timeframe,
            candles=candles
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch chart: {str(e)}")
