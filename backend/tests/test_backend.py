import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.market_data_service import market_service
from app.services.feature_engine import feature_engine
from app.services.ml_models import ml_models
from app.services.risk_engine import risk_engine
from app.services.backtesting_engine import backtesting_engine

client = TestClient(app)

def test_root_and_health():
    res = client.get("/")
    assert res.status_code == 200
    assert res.json()["status"] == "online"

    health = client.get("/health")
    assert health.status_code == 200
    assert health.json()["status"] == "healthy"

def test_stocks_endpoint():
    res = client.get("/api/v1/stocks")
    assert res.status_code == 200
    data = res.json()
    assert len(data) >= 5
    symbols = [s["symbol"] for s in data]
    assert "RELIANCE" in symbols
    assert "TCS" in symbols

def test_market_status():
    res = client.get("/api/v1/market/status")
    assert res.status_code == 200
    data = res.json()
    assert "regime" in data
    assert data["nifty50_price"] > 0

def test_chart_data():
    res = client.get("/api/v1/market/RELIANCE/chart?timeframe=1M")
    assert res.status_code == 200
    data = res.json()
    assert data["symbol"] == "RELIANCE"
    assert len(data["candles"]) > 0
    first_candle = data["candles"][0]
    assert "open" in first_candle
    assert "close" in first_candle

def test_feature_engine_indicators():
    df = market_service.fetch_ohlcv("RELIANCE", "1M")
    enriched = feature_engine.calculate_indicators(df)
    assert "rsi" in enriched.columns
    assert "macd" in enriched.columns
    assert "ema20" in enriched.columns
    assert "vwap" in enriched.columns
    assert "atr" in enriched.columns
    assert "adx" in enriched.columns
    assert "cmf" in enriched.columns
    assert "stoch_k" in enriched.columns
    assert "supertrend" in enriched.columns

def test_prediction_intraday():
    res = client.get("/api/v1/prediction/RELIANCE?mode=intraday")
    assert res.status_code == 200
    data = res.json()
    assert data["mode"] == "intraday"
    assert data["signal"] in ["BUY", "SELL", "HOLD"]
    assert 0.0 <= data["confidence"] <= 1.0
    assert 60.0 <= data["accuracy_rate"] <= 95.0
    assert 30.0 <= data["consensus_score"] <= 100.0
    assert data["validation_model"] is not None
    assert "Bayesian" in data["validation_model"]["model_name"]
    assert data["target"] > 0
    assert data["stop_loss"] > 0
    assert len(data["reasons"]) > 0
    assert len(data["risk_factors"]) > 0

def test_prediction_swing():
    res = client.get("/api/v1/prediction/TCS?mode=swing")
    assert res.status_code == 200
    data = res.json()
    assert data["mode"] == "swing"
    assert data["signal"] in ["BUY", "SELL", "HOLD"]
    assert data["horizon"] == "5 trading days (Swing)"
    assert 60.0 <= data["accuracy_rate"] <= 95.0
    assert data["validation_model"] is not None

def test_prediction_investment():
    res = client.get("/api/v1/prediction/INFY?mode=investment")
    assert res.status_code == 200
    data = res.json()
    assert data["mode"] == "investment"
    assert data["signal"] in ["ACCUMULATE", "BUY", "HOLD", "AVOID"]
    assert data["investment_score"] is not None
    assert 0 <= data["investment_score"]["overall"] <= 100
    assert 60.0 <= data["accuracy_rate"] <= 95.0
    assert data["validation_model"] is not None

def test_risk_engine_position_sizing():
    res = client.post("/api/v1/risk/calculate-position", json={
        "capital": 100000.0,
        "risk_percent": 1.0,
        "entry_price": 1420.0,
        "stop_loss": 1400.0,
        "target_price": 1490.0
    })
    assert res.status_code == 200
    data = res.json()
    assert data["max_risk_amount"] == 1000.0
    assert data["risk_per_share"] == 20.0
    assert data["recommended_shares"] == 50
    assert data["total_position_value"] == 71000.0
    assert data["risk_reward_ratio"] == 3.5

def test_backtest_endpoint():
    res = client.get("/api/v1/backtest/RELIANCE?mode=swing")
    assert res.status_code == 200
    data = res.json()
    assert data["symbol"] == "RELIANCE"
    assert "win_rate" in data
    assert "profit_factor" in data
    assert "total_trades" in data

def test_prediction_news_and_strategy_study():
    res = client.get("/api/v1/prediction/RELIANCE?mode=swing")
    assert res.status_code == 200
    data = res.json()
    assert "news_study" in data and data["news_study"] is not None
    assert "sentiment_label" in data["news_study"]
    assert "top_headlines" in data["news_study"]
    assert "strategy_study" in data and data["strategy_study"] is not None
    assert "strategy_name" in data["strategy_study"]
    assert "timeframe_plan" in data["strategy_study"]
    assert "historical_win_rate" in data and data["historical_win_rate"] is not None

def test_prediction_history_endpoint():
    res = client.get("/api/v1/prediction/TCS/history?mode=swing")
    assert res.status_code == 200
    data = res.json()
    assert data["symbol"] == "TCS"
    assert data["mode"] == "swing"
    assert "total_predictions" in data
    assert "win_rate" in data
    assert "predictions" in data

def test_dynamic_stocks_search():
    res = client.get("/api/v1/stocks/search?q=TCS")
    assert res.status_code == 200
    data = res.json()
    assert len(data) >= 1
    assert any("TCS" in s["symbol"] for s in data)

