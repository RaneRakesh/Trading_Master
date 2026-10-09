from concurrent.futures import ThreadPoolExecutor
from fastapi import APIRouter, HTTPException, Query
from typing import List
from app.models.schemas import StockQuote
from app.services.market_data_service import market_service

router = APIRouter(prefix="/api/v1/stocks", tags=["stocks"])

@router.get("", response_model=List[StockQuote])
def get_all_stocks():
    """Returns quotes for all tracked equity symbols concurrently."""
    def _fetch(symbol: str):
        try:
            return market_service.get_quote(symbol)
        except Exception:
            return None

    symbols = market_service.get_all_tracked_symbols()
    with ThreadPoolExecutor(max_workers=10) as executor:
        results = list(executor.map(_fetch, symbols))

    return [q for q in results if q is not None]

@router.get("/search", response_model=List[StockQuote])
def search_stocks(q: str = Query(..., min_length=1, description="Symbol or company name to search")):
    """Dynamically searches or discovers any stock symbol via live market data."""
    try:
        return market_service.search_stocks(q)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@router.get("/{symbol}", response_model=StockQuote)
def get_stock(symbol: str):
    """Returns quote for a specific equity symbol."""
    sym = symbol.upper().strip()
    try:
        return market_service.get_quote(sym)
    except Exception as e:
        raise HTTPException(status_code=404, detail=f"Stock {symbol} not found: {str(e)}")
