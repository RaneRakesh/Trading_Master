from fastapi import APIRouter, Query, HTTPException
from app.models.schemas import BacktestResponse
from app.services.market_data_service import market_service
from app.services.backtesting_engine import backtesting_engine

router = APIRouter(prefix="/api/v1/backtest", tags=["backtest"])

@router.get("/{symbol}", response_model=BacktestResponse)
def run_backtest(
    symbol: str,
    mode: str = Query("swing", pattern="^(intraday|swing|investment)$"),
    capital: float = Query(100000.0, ge=1000.0)
):
    """
    Simulates walk-forward historical backtest for the specified symbol & strategy mode.
    (Blueprint Section 18)
    """
    timeframe = "1Y" if mode in ["swing", "investment"] else "5D"
    df = market_service.fetch_ohlcv(symbol, timeframe)
    if df.empty:
        raise HTTPException(status_code=404, detail=f"No historical data for {symbol}")

    return backtesting_engine.run_backtest(
        df=df,
        symbol=symbol,
        mode=mode,
        initial_capital=capital
    )
