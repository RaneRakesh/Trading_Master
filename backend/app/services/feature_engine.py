import pandas as pd
import numpy as np
from typing import Dict, Any

class FeatureEngine:
    @staticmethod
    def calculate_indicators(df: pd.DataFrame) -> pd.DataFrame:
        """
        Takes an OHLCV dataframe and computes all required technical indicators:
        SMA, EMA, RSI, MACD, ATR, VWAP, Bollinger Bands, Volume Ratio, and returns.
        """
        df = df.copy()
        if len(df) < 5:
            return df

        # Ensure numeric
        for col in ["open", "high", "low", "close", "volume"]:
            df[col] = pd.to_numeric(df[col], errors="coerce")

        close = df["close"]
        high = df["high"]
        low = df["low"]
        volume = df["volume"].replace(0, 1)

        # 1. Moving Averages
        df["ema9"] = close.ewm(span=9, adjust=False).mean()
        df["ema20"] = close.ewm(span=20, adjust=False).mean()
        df["ema50"] = close.ewm(span=50, adjust=False).mean()
        df["ema200"] = close.ewm(span=min(200, len(df)), adjust=False).mean()

        df["sma20"] = close.rolling(window=min(20, len(df)), min_periods=1).mean()
        df["sma50"] = close.rolling(window=min(50, len(df)), min_periods=1).mean()
        df["sma200"] = close.rolling(window=min(200, len(df)), min_periods=1).mean()

        # 2. RSI (14)
        delta = close.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=14, min_periods=1).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=14, min_periods=1).mean()
        rs = gain / (loss + 1e-9)
        df["rsi"] = 100 - (100 / (1 + rs))

        # 3. MACD (12, 26, 9)
        ema12 = close.ewm(span=12, adjust=False).mean()
        ema26 = close.ewm(span=26, adjust=False).mean()
        df["macd"] = ema12 - ema26
        df["macd_signal"] = df["macd"].ewm(span=9, adjust=False).mean()
        df["macd_hist"] = df["macd"] - df["macd_signal"]

        # 4. ATR (14)
        tr1 = high - low
        tr2 = (high - close.shift(1)).abs()
        tr3 = (low - close.shift(1)).abs()
        tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
        df["atr"] = tr.rolling(window=14, min_periods=1).mean()

        # 5. Bollinger Bands (20, 2)
        std20 = close.rolling(window=min(20, len(df)), min_periods=1).std().fillna(0)
        df["bb_middle"] = df["sma20"]
        df["bb_upper"] = df["bb_middle"] + (2 * std20)
        df["bb_lower"] = df["bb_middle"] - (2 * std20)

        # 6. VWAP
        typical_price = (high + low + close) / 3.0
        df["vwap"] = (typical_price * volume).cumsum() / volume.cumsum()

        # 7. Volume SMA and Volume Ratio
        df["volume_sma20"] = volume.rolling(window=min(20, len(df)), min_periods=1).mean()
        df["volume_ratio"] = volume / (df["volume_sma20"] + 1e-9)

        # 8. Stochastic Oscillator (14, 3, 3)
        low14 = low.rolling(window=14, min_periods=1).min()
        high14 = high.rolling(window=14, min_periods=1).max()
        stoch_k = 100 * ((close - low14) / (high14 - low14 + 1e-9))
        df["stoch_k"] = stoch_k
        df["stoch_d"] = stoch_k.rolling(window=3, min_periods=1).mean()

        # 9. Chaikin Money Flow (CMF 20)
        mfm = ((close - low) - (high - close)) / (high - low + 1e-9)
        mfv = mfm * volume
        vol_sum20 = volume.rolling(window=min(20, len(df)), min_periods=1).sum()
        df["cmf"] = mfv.rolling(window=min(20, len(df)), min_periods=1).sum() / (vol_sum20 + 1e-9)

        # 10. ADX (Average Directional Index) & Directional Movement (+DI, -DI)
        up_move = high.diff()
        down_move = -low.diff()
        plus_dm = pd.Series(np.where((up_move > down_move) & (up_move > 0), up_move, 0.0), index=df.index)
        minus_dm = pd.Series(np.where((down_move > up_move) & (down_move > 0), down_move, 0.0), index=df.index)
        
        atr_smooth = df["atr"].replace(0, 1e-9)
        plus_di = 100 * (plus_dm.ewm(span=14, adjust=False).mean() / atr_smooth)
        minus_di = 100 * (minus_dm.ewm(span=14, adjust=False).mean() / atr_smooth)
        dx = 100 * ((plus_di - minus_di).abs() / (plus_di + minus_di + 1e-9))
        df["plus_di"] = plus_di
        df["minus_di"] = minus_di
        df["adx"] = dx.ewm(span=14, adjust=False).mean()

        # 11. SuperTrend (10, 3.0)
        hl2 = (high + low) / 2.0
        multiplier = 3.0
        atr10 = tr.rolling(window=10, min_periods=1).mean()
        basic_upper = hl2 + (multiplier * atr10)
        basic_lower = hl2 - (multiplier * atr10)

        upper_band = basic_upper.copy()
        lower_band = basic_lower.copy()
        supertrend = pd.Series(0.0, index=df.index)
        supertrend_direction = pd.Series(1, index=df.index)  # 1 = Bullish, -1 = Bearish

        close_vals = close.values
        b_up = basic_upper.values
        b_low = basic_lower.values
        u_band = upper_band.values
        l_band = lower_band.values
        st_vals = supertrend.values
        st_dir = supertrend_direction.values

        for i in range(1, len(df)):
            if b_low[i] > l_band[i - 1] or close_vals[i - 1] < l_band[i - 1]:
                l_band[i] = b_low[i]
            else:
                l_band[i] = l_band[i - 1]

            if b_up[i] < u_band[i - 1] or close_vals[i - 1] > u_band[i - 1]:
                u_band[i] = b_up[i]
            else:
                u_band[i] = u_band[i - 1]

            if close_vals[i] > u_band[i - 1]:
                st_dir[i] = 1
            elif close_vals[i] < l_band[i - 1]:
                st_dir[i] = -1
            else:
                st_dir[i] = st_dir[i - 1]

            st_vals[i] = l_band[i] if st_dir[i] == 1 else u_band[i]

        df["supertrend"] = st_vals
        df["supertrend_dir"] = st_dir

        # 12. Volatility Z-score
        rolling_std = close.pct_change().rolling(window=min(20, len(df)), min_periods=1).std().fillna(0)
        mean_std = rolling_std.rolling(window=min(50, len(df)), min_periods=1).mean().fillna(0)
        std_std = rolling_std.rolling(window=min(50, len(df)), min_periods=1).std().fillna(1e-9)
        df["vol_zscore"] = (rolling_std - mean_std) / (std_std + 1e-9)

        # 13. Price Action / Returns
        df["return_1"] = close.pct_change(1).fillna(0)
        df["return_3"] = close.pct_change(3).fillna(0)
        df["return_5"] = close.pct_change(5).fillna(0)
        df["return_10"] = close.pct_change(10).fillna(0)
        df["dist_ema20"] = (close - df["ema20"]) / df["ema20"]
        df["dist_vwap"] = (close - df["vwap"]) / df["vwap"]

        return df

    @staticmethod
    def get_latest_indicators(df: pd.DataFrame, symbol: str) -> Dict[str, Any]:
        enriched = FeatureEngine.calculate_indicators(df)
        latest = enriched.iloc[-1]

        return {
            "symbol": symbol.upper(),
            "timestamp": str(latest["timestamp"]),
            "rsi": round(float(latest.get("rsi", 50.0)), 2),
            "macd": round(float(latest.get("macd", 0.0)), 2),
            "macd_signal": round(float(latest.get("macd_signal", 0.0)), 2),
            "macd_hist": round(float(latest.get("macd_hist", 0.0)), 2),
            "ema9": round(float(latest.get("ema9", latest["close"])), 2),
            "ema20": round(float(latest.get("ema20", latest["close"])), 2),
            "ema50": round(float(latest.get("ema50", latest["close"])), 2),
            "ema200": round(float(latest.get("ema200", latest["close"])), 2),
            "sma20": round(float(latest.get("sma20", latest["close"])), 2),
            "sma50": round(float(latest.get("sma50", latest["close"])), 2),
            "sma200": round(float(latest.get("sma200", latest["close"])), 2),
            "atr": round(float(latest.get("atr", latest["close"] * 0.015)), 2),
            "vwap": round(float(latest.get("vwap", latest["close"])), 2),
            "bb_upper": round(float(latest.get("bb_upper", latest["close"] * 1.05)), 2),
            "bb_middle": round(float(latest.get("bb_middle", latest["close"])), 2),
            "bb_lower": round(float(latest.get("bb_lower", latest["close"] * 0.95)), 2),
            "volume_ratio": round(float(latest.get("volume_ratio", 1.0)), 2),
            "adx": round(float(latest.get("adx", 25.0)), 2),
            "plus_di": round(float(latest.get("plus_di", 25.0)), 2),
            "minus_di": round(float(latest.get("minus_di", 25.0)), 2),
            "stoch_k": round(float(latest.get("stoch_k", 50.0)), 2),
            "stoch_d": round(float(latest.get("stoch_d", 50.0)), 2),
            "cmf": round(float(latest.get("cmf", 0.0)), 3),
            "supertrend": round(float(latest.get("supertrend", latest["close"])), 2),
            "supertrend_dir": int(latest.get("supertrend_dir", 1)),
            "vol_zscore": round(float(latest.get("vol_zscore", 0.0)), 2)
        }

feature_engine = FeatureEngine()
