from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import stocks, market, predictions, backtest

app = FastAPI(
    title="Trading Master AI Decision Support Engine",
    description="Intelligent financial ML prediction and risk engine for Intraday, Swing, and Investment modes",
    version="1.0.0"
)

# Enable CORS for Flutter Web / Mobile / Desktop
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount feature routers
app.include_router(stocks.router)
app.include_router(market.router)
app.include_router(predictions.router)
app.include_router(backtest.router)

@app.get("/")
def root():
    return {
        "app": "Trading Master AI Engine",
        "status": "online",
        "docs": "/docs",
        "endpoints": [
            "/api/v1/stocks",
            "/api/v1/market/status",
            "/api/v1/market/{symbol}/chart",
            "/api/v1/prediction/{symbol}?mode=intraday|swing|investment",
            "/api/v1/indicators/{symbol}",
            "/api/v1/risk/calculate-position",
            "/api/v1/backtest/{symbol}"
        ]
    }

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "trading_master_backend"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)
