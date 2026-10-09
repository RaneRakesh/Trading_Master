import pandas as pd
import numpy as np
from typing import List, Dict, Any
from app.models.schemas import BacktestResponse, BacktestTrade
from app.services.feature_engine import FeatureEngine

class BacktestingEngine:
    """
    Simulates walk-forward historical performance for trading strategies.
    Ensures strict chronological walk-forward execution to avoid lookahead bias.
    (Blueprint Sections 16, 17, 18, 19)
    """

    @staticmethod
    def run_backtest(df: pd.DataFrame, symbol: str, mode: str = "swing", initial_capital: float = 100000.0) -> BacktestResponse:
        enriched = FeatureEngine.calculate_indicators(df)
        if len(enriched) < 20:
            return BacktestResponse(
                symbol=symbol.upper(),
                mode=mode,
                initial_capital=initial_capital,
                final_capital=initial_capital,
                total_trades=0,
                winning_trades=0,
                losing_trades=0,
                win_rate=0.0,
                total_return_percent=0.0,
                profit_factor=1.0,
                max_drawdown_percent=0.0,
                trades=[]
            )

        trades: List[BacktestTrade] = []
        in_position = False
        entry_price = 0.0
        entry_date = ""
        target_price = 0.0
        stop_price = 0.0
        capital = initial_capital
        peak_capital = initial_capital
        max_drawdown = 0.0
        total_gains = 0.0
        total_losses = 0.0

        candles = enriched.to_dict("records")
        # Step chronologically through candles
        for i in range(15, len(candles) - 1):
            curr = candles[i]
            next_c = candles[i + 1]

            if not in_position:
                # Signal Generation logic based on indicators
                rsi = curr.get("rsi", 50.0)
                ema20 = curr.get("ema20", curr["close"])
                ema50 = curr.get("ema50", curr["close"])
                atr = curr.get("atr", curr["close"] * 0.02)

                # Bullish setup
                if curr["close"] > ema20 and ema20 > ema50 and (48 <= rsi <= 68):
                    in_position = True
                    entry_price = curr["close"]
                    entry_date = str(curr["timestamp"])
                    target_price = entry_price + (2.0 * atr)
                    stop_price = entry_price - (1.0 * atr)
            else:
                # Check exit condition on candle
                high = next_c["high"]
                low = next_c["low"]
                close = next_c["close"]
                exit_date = str(next_c["timestamp"])

                exit_trade = False
                exit_price = close
                reason = "Horizon Expiry"

                if high >= target_price:
                    exit_price = target_price
                    exit_trade = True
                    reason = "Target Hit"
                elif low <= stop_price:
                    exit_price = stop_price
                    exit_trade = True
                    reason = "Stop Loss Hit"

                if exit_trade:
                    pct = ((exit_price - entry_price) / entry_price) * 100.0
                    risk_capital = capital * 0.05  # 5% allocated per trade
                    pnl = risk_capital * (pct / 100.0)
                    capital += pnl

                    if capital > peak_capital:
                        peak_capital = capital
                    dd = ((peak_capital - capital) / peak_capital) * 100.0
                    if dd > max_drawdown:
                        max_drawdown = dd

                    if pnl > 0:
                        total_gains += pnl
                    else:
                        total_losses += abs(pnl)

                    trades.append(BacktestTrade(
                        entry_date=entry_date,
                        exit_date=exit_date,
                        type="BUY",
                        entry_price=round(entry_price, 2),
                        exit_price=round(exit_price, 2),
                        pnl=round(pnl, 2),
                        return_percent=round(pct, 2),
                        reason=reason
                    ))
                    in_position = False

        total_trades = len(trades)
        winning_trades = sum(1 for t in trades if t.pnl > 0)
        losing_trades = total_trades - winning_trades
        win_rate = round((winning_trades / total_trades * 100.0), 1) if total_trades > 0 else 0.0
        profit_factor = round(total_gains / (total_losses + 1e-6), 2) if total_losses > 0 else (2.5 if total_gains > 0 else 1.0)
        total_return_pct = round(((capital - initial_capital) / initial_capital) * 100.0, 2)

        return BacktestResponse(
            symbol=symbol.upper(),
            mode=mode,
            initial_capital=round(initial_capital, 2),
            final_capital=round(capital, 2),
            total_trades=total_trades,
            winning_trades=winning_trades,
            losing_trades=losing_trades,
            win_rate=win_rate,
            total_return_percent=total_return_pct,
            profit_factor=profit_factor,
            max_drawdown_percent=round(max_drawdown, 2),
            trades=trades[-15:]  # Return most recent 15 trades
        )

backtesting_engine = BacktestingEngine()
