from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any

class StockQuote(BaseModel):
    symbol: str
    company_name: str
    exchange: str = "NSE"
    sector: str
    current_price: float
    change: float
    change_percent: float
    open: float
    high: float
    low: float
    close: float
    volume: int
    timestamp: str
    is_trending: Optional[bool] = False
    pe_ratio: Optional[float] = None
    market_cap: Optional[float] = None
    fifty_two_week_high: Optional[float] = None
    fifty_two_week_low: Optional[float] = None

class Candle(BaseModel):
    timestamp: str
    open: float
    high: float
    low: float
    close: float
    volume: int

class ChartDataResponse(BaseModel):
    symbol: str
    timeframe: str
    candles: List[Candle]

class TechnicalIndicators(BaseModel):
    symbol: str
    timestamp: str
    rsi: float
    macd: float
    macd_signal: float
    macd_hist: float
    ema9: float
    ema20: float
    ema50: float
    ema200: float
    sma20: float
    sma50: float
    sma200: float
    atr: float
    vwap: float
    bb_upper: float
    bb_middle: float
    bb_lower: float
    volume_ratio: float
    adx: Optional[float] = 25.0
    plus_di: Optional[float] = 25.0
    minus_di: Optional[float] = 25.0
    stoch_k: Optional[float] = 50.0
    stoch_d: Optional[float] = 50.0
    cmf: Optional[float] = 0.0
    supertrend: Optional[float] = None
    supertrend_dir: Optional[int] = 1
    vol_zscore: Optional[float] = 0.0

class ValidationModelSummary(BaseModel):
    model_name: str
    signal: str
    direction: str
    probability: float
    confidence: float
    agrees_with_primary: bool
    validation_note: str

class InvestmentScorecard(BaseModel):
    fundamentals: float = Field(..., description="Score 0-100")
    growth: float = Field(..., description="Score 0-100")
    valuation: float = Field(..., description="Score 0-100")
    technical_trend: float = Field(..., description="Score 0-100")
    risk_score: float = Field(..., description="Score 0-100")
    overall: float = Field(..., description="Score 0-100")
    pe_ratio: Optional[float] = None
    pb_ratio: Optional[float] = None
    roe: Optional[float] = None
    debt_to_equity: Optional[float] = None

class NewsItem(BaseModel):
    title: str
    publisher: str
    published_at: str
    url: Optional[str] = None
    sentiment: str  # BULLISH, BEARISH, NEUTRAL
    sentiment_score: float  # -1.0 to 1.0

class NewsSentimentStudy(BaseModel):
    sentiment_label: str  # BULLISH CATALYST, NEUTRAL, BEARISH HEADWIND
    sentiment_score: float
    total_articles: int
    catalyst_summary: str
    top_headlines: List[NewsItem]

class StrategyStudy(BaseModel):
    strategy_name: str
    strategy_description: str
    timeframe_plan: str
    key_confluences: List[str]
    risk_management_rule: str
    internet_study_source: str

class PredictionResponse(BaseModel):
    symbol: str
    mode: str  # intraday, swing, investment
    timestamp: str
    current_price: float
    signal: str  # BUY, SELL, HOLD, ACCUMULATE
    direction: str  # BULLISH, BEARISH, NEUTRAL
    probability: float  # 0.0 - 1.0
    confidence: float   # 0.0 - 1.0
    accuracy_rate: float = Field(..., description="Historical prediction accuracy percentage (e.g. 78.4%)")
    consensus_score: float = Field(..., description="Dual-model consensus percentage (e.g. 92.0%)")
    target: float
    stop_loss: float
    risk_reward_ratio: float
    horizon: str
    risk_level: str  # Low, Medium, High
    reasons: List[str]
    risk_factors: List[str]
    model_version: str
    validation_model: Optional[ValidationModelSummary] = None
    investment_score: Optional[InvestmentScorecard] = None
    news_study: Optional[NewsSentimentStudy] = None
    strategy_study: Optional[StrategyStudy] = None
    historical_win_rate: Optional[float] = None

class PositionSizeRequest(BaseModel):
    capital: float = 100000.0
    risk_percent: float = 1.0
    entry_price: float
    stop_loss: float
    target_price: Optional[float] = None

class PositionSizeResponse(BaseModel):
    capital: float
    risk_percent: float
    max_risk_amount: float
    risk_per_share: float
    recommended_shares: int
    total_position_value: float
    capital_allocated_percent: float
    target_price: Optional[float] = None
    potential_profit: Optional[float] = None
    risk_reward_ratio: Optional[float] = None

class BacktestTrade(BaseModel):
    entry_date: str
    exit_date: str
    type: str
    entry_price: float
    exit_price: float
    pnl: float
    return_percent: float
    reason: str

class BacktestResponse(BaseModel):
    symbol: str
    mode: str
    initial_capital: float
    final_capital: float
    total_trades: int
    winning_trades: int
    losing_trades: int
    win_rate: float
    total_return_percent: float
    profit_factor: float
    max_drawdown_percent: float
    trades: List[BacktestTrade]

class PredictionHistoryItem(BaseModel):
    timestamp: str
    signal: str
    entry_price: float
    target: float
    stop_loss: float
    result: str  # TARGET_HIT, STOP_LOSS_HIT, ACTIVE
    return_percent: float
    pnl: float

class PredictionHistoryResponse(BaseModel):
    symbol: str
    mode: str
    total_predictions: int
    win_rate: float
    profit_factor: float
    predictions: List[PredictionHistoryItem]

class MarketStatusResponse(BaseModel):
    nse_status: str
    nifty50_price: float
    nifty50_change: float
    nifty50_percent: float
    banknifty_price: float
    banknifty_change: float
    banknifty_percent: float
    regime: str
    regime_description: str
    timestamp: str
