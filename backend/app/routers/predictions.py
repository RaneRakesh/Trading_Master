import datetime
from fastapi import APIRouter, Query, HTTPException
from app.models.schemas import (
    PredictionResponse,
    TechnicalIndicators,
    PositionSizeRequest,
    PositionSizeResponse,
    PredictionHistoryResponse
)
from app.services.market_data_service import market_service
from app.services.feature_engine import feature_engine
from app.services.ml_models import ml_models
from app.services.signal_engine import signal_engine
from app.services.risk_engine import risk_engine
from app.services.news_service import news_service
from app.services.prediction_history_service import prediction_history_service

router = APIRouter(prefix="/api/v1", tags=["predictions"])

@router.get("/prediction/{symbol}", response_model=PredictionResponse)
def get_prediction(symbol: str, mode: str = Query("swing", pattern="^(intraday|swing|investment)$")):
    """
    Returns dynamic AI prediction, target, stop loss, calibrated probability,
    transparent reasoning, real-time news catalysts study, strategy study,
    and verified historical win rate for the chosen trading mode.
    """
    sym = symbol.upper().strip()
    info = market_service.get_stock_info(sym)

    # Timeframe selection based on mode
    timeframe_map = {
        "intraday": "1D",
        "swing": "1M",
        "investment": "1Y"
    }
    tf = timeframe_map[mode]
    df = market_service.fetch_ohlcv(sym, tf)
    if df.empty:
        raise HTTPException(status_code=404, detail="Candle history unavailable")

    current_price = round(float(df.iloc[-1]["close"]), 2)

    # 1. Fetch dynamic web news & catalyst study
    news_study = news_service.get_news_study(sym, info.get("name", sym))
    news_score = news_study.sentiment_score

    # 2. Call specific mode model with live news catalyst factor
    if mode == "intraday":
        pred = ml_models.predict_intraday(df, current_price, news_score=news_score)
    elif mode == "swing":
        pred = ml_models.predict_swing(df, current_price, news_score=news_score)
    else:
        pred = ml_models.predict_investment(df, info, current_price, news_score=news_score)

    # 3. Evaluate Accuracy Rate % and Dual-Model Consensus Assurance
    accuracy_rate, consensus_score, val_summary = ml_models.evaluate_model_accuracy_and_consensus(
        primary_pred=pred,
        df=df,
        current_price=current_price,
        mode=mode
    )

    # 4. Calculate risk-reward ratio
    risk_dist = abs(current_price - pred["stop_loss"])
    reward_dist = abs(pred["target"] - current_price)
    rr_ratio = round(reward_dist / (risk_dist + 1e-6), 2)

    # 5. Extract indicators & generate human-readable explanations
    metrics = pred.get("metrics", {})
    inv_score = pred.get("investment_score")
    reasons, risk_factors, risk_level = signal_engine.generate_explanations(
        mode=mode,
        signal=pred["signal"],
        current_price=current_price,
        target=pred["target"],
        stop_loss=pred["stop_loss"],
        metrics=metrics,
        investment_score=inv_score
    )

    # 6. Generate detailed strategy study & internet research
    strategy_study = ml_models.generate_strategy_study(
        mode=mode,
        signal=pred["signal"],
        metrics=metrics,
        news_score=news_score
    )

    # 7. Evaluate historical prediction win rate
    history_resp = prediction_history_service.get_prediction_history(
        symbol=sym,
        mode=mode,
        df=df,
        current_price=current_price
    )

    now = datetime.datetime.now()
    return PredictionResponse(
        symbol=sym,
        mode=mode,
        timestamp=now.strftime("%Y-%m-%d %H:%M:%S"),
        current_price=current_price,
        signal=pred["signal"],
        direction=pred["direction"],
        probability=pred["probability"],
        confidence=pred["confidence"],
        accuracy_rate=accuracy_rate,
        consensus_score=consensus_score,
        target=pred["target"],
        stop_loss=pred["stop_loss"],
        risk_reward_ratio=rr_ratio,
        horizon=pred["horizon"],
        risk_level=risk_level,
        reasons=reasons,
        risk_factors=risk_factors,
        model_version=pred["model_version"],
        validation_model=val_summary,
        investment_score=inv_score,
        news_study=news_study,
        strategy_study=strategy_study,
        historical_win_rate=history_resp.win_rate
    )

@router.get("/prediction/{symbol}/history", response_model=PredictionHistoryResponse)
def get_prediction_history(
    symbol: str,
    mode: str = Query("swing", pattern="^(intraday|swing|investment)$")
):
    """
    Returns audited historical predictions track record, trade outcomes,
    and empirically verified win rate for the specified symbol and mode.
    """
    sym = symbol.upper().strip()
    timeframe_map = {
        "intraday": "1D",
        "swing": "1M",
        "investment": "1Y"
    }
    tf = timeframe_map[mode]
    df = market_service.fetch_ohlcv(sym, tf)
    if df.empty:
        raise HTTPException(status_code=404, detail="Candle history unavailable")

    current_price = round(float(df.iloc[-1]["close"]), 2)
    return prediction_history_service.get_prediction_history(
        symbol=sym,
        mode=mode,
        df=df,
        current_price=current_price
    )

@router.get("/indicators/{symbol}", response_model=TechnicalIndicators)
def get_indicators(symbol: str, timeframe: str = Query("1M", pattern="^(1D|5D|1M|6M|1Y)$")):
    """Returns calculated technical indicators for the stock."""
    df = market_service.fetch_ohlcv(symbol, timeframe)
    data = feature_engine.get_latest_indicators(df, symbol)
    return TechnicalIndicators(**data)

@router.post("/risk/calculate-position", response_model=PositionSizeResponse)
def calculate_position(req: PositionSizeRequest):
    """Calculates position size and risk metrics based on capital and stop loss."""
    return risk_engine.calculate_position_size(
        capital=req.capital,
        risk_percent=req.risk_percent,
        entry_price=req.entry_price,
        stop_loss=req.stop_loss,
        target_price=req.target_price
    )
