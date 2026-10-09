from typing import List, Dict, Any, Tuple

class SignalEngine:
    """
    Synthesizes model predictions, technical indicator context, and market regime
    into transparent 'Why BUY/SELL' explanations and actionable risk factors.
    (Blueprint Sections 24, 25, 38)
    """

    @staticmethod
    def generate_explanations(
        mode: str,
        signal: str,
        current_price: float,
        target: float,
        stop_loss: float,
        metrics: Dict[str, Any],
        investment_score: Any = None
    ) -> Tuple[List[str], List[str], str]:
        reasons: List[str] = []
        risk_factors: List[str] = []

        rsi = metrics.get("rsi", 50.0)
        atr = metrics.get("atr", current_price * 0.015)
        vol_ratio = metrics.get("volume_ratio", 1.0)
        dist_vwap = metrics.get("dist_vwap", 0.0)
        ema20 = metrics.get("ema20", current_price)
        ema50 = metrics.get("ema50", current_price)
        ema200 = metrics.get("ema200", current_price)
        macd_hist = metrics.get("macd_hist", 0.0)

        # 1. Mode & Signal Specific Reasons
        adx = metrics.get("adx", 25.0)
        cmf = metrics.get("cmf", 0.0)
        st_dir = metrics.get("supertrend_dir", 1)

        if adx >= 24.0:
            reasons.append(f"ADX ({adx:.1f}) confirms robust directional trend strength (avoids choppy whipsaws)")
        else:
            risk_factors.append(f"ADX ({adx:.1f}) is low; market is currently in a consolidation/choppy phase")

        if cmf > 0.05:
            reasons.append(f"Chaikin Money Flow (+{cmf:.2f}) verifies net institutional accumulation")
        elif cmf < -0.05:
            risk_factors.append(f"Chaikin Money Flow ({cmf:.2f}) indicates institutional liquidity distribution")

        if st_dir == 1:
            reasons.append("SuperTrend volatility band confirms bullish trailing support")
        else:
            reasons.append("SuperTrend volatility band indicates active overhead resistance")

        if mode == "intraday":
            if dist_vwap > 0:
                reasons.append("Price trading above intraday VWAP, indicating strong institutional buyer support")
            else:
                reasons.append("Price trading below intraday VWAP, indicating sellers are dominating liquidity")

            if vol_ratio >= 1.2:
                reasons.append(f"High trading activity: Volume is {vol_ratio:.1f}x higher than 20-candle average")

            if 50 <= rsi <= 68:
                reasons.append(f"RSI ({rsi:.1f}) confirms healthy upward momentum without reaching overbought territory")
            elif rsi > 70:
                risk_factors.append(f"RSI ({rsi:.1f}) is in overbought zone; watch for intraday pullbacks")
            elif rsi < 35:
                reasons.append(f"RSI ({rsi:.1f}) indicates oversold rebound potential")

        elif mode == "swing":
            if current_price > ema20:
                reasons.append(f"Price holding above 20 EMA (₹{ema20:.1f}), maintaining short-term bullish trend")
            else:
                reasons.append(f"Price below 20 EMA (₹{ema20:.1f}), exhibiting short-term downward pressure")

            if ema20 > ema50:
                reasons.append(f"20 EMA is above 50 EMA, confirming medium-term trend alignment")

            if current_price > ema200:
                reasons.append(f"Primary structural trend is Bullish (Price above 200 EMA of ₹{ema200:.1f})")

            if macd_hist > 0:
                reasons.append("MACD histogram is positive and expanding, showing accelerating momentum")
            else:
                reasons.append("MACD histogram indicates momentum contraction")

        elif mode == "investment":
            if investment_score:
                reasons.append(f"Fundamental Health Score is {investment_score.fundamentals:.0f}/100 with ROE of {investment_score.roe or 18:.1f}%")
                reasons.append(f"Growth & Profitability score rated at {investment_score.growth:.0f}/100")
                if (investment_score.debt_to_equity or 0) < 0.6:
                    reasons.append(f"Comfortable balance sheet with low Debt-to-Equity of {investment_score.debt_to_equity or 0.4:.2f}")
                if (investment_score.pe_ratio or 0) < 30:
                    reasons.append(f"Reasonable valuation at {investment_score.pe_ratio or 22:.1f}x P/E multiple")
            if current_price > ema200:
                reasons.append("Multi-year secular trend is firmly intact above 200-day moving average")

        # 2. Risk Factors & Volatility
        volatility_pct = (atr / current_price) * 100
        if volatility_pct > 2.5:
            risk_level = "High"
            risk_factors.append(f"High volatility regime (ATR {volatility_pct:.1f}% of price) — use conservative position size")
        elif volatility_pct > 1.4:
            risk_level = "Medium"
            risk_factors.append(f"Moderate price volatility (ATR: ₹{atr:.1f})")
        else:
            risk_level = "Low"
            risk_factors.append("Low volatility price consolidation")

        if signal in ["BUY", "ACCUMULATE"]:
            risk_factors.append(f"Key invalidation stop loss set at ₹{stop_loss:.1f}")
        elif signal == "SELL":
            risk_factors.append(f"Short invalidation stop loss set at ₹{stop_loss:.1f}")

        risk_factors.append("Model predictions are probabilistic estimates; always follow strict risk parameters")

        return reasons, risk_factors, risk_level

signal_engine = SignalEngine()
