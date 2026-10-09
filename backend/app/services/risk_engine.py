from typing import Optional
from app.models.schemas import PositionSizeResponse

class RiskEngine:
    """
    Risk Engine for calculating dynamic position sizing, risk/reward ratio,
    and portfolio capital protection (Blueprint Section 26).
    """

    @staticmethod
    def calculate_position_size(
        capital: float,
        risk_percent: float,
        entry_price: float,
        stop_loss: float,
        target_price: Optional[float] = None
    ) -> PositionSizeResponse:
        risk_per_share = abs(entry_price - stop_loss)
        if risk_per_share <= 0:
            risk_per_share = entry_price * 0.01  # Safe default 1%

        max_risk_amount = round(capital * (risk_percent / 100.0), 2)
        recommended_shares = int(max_risk_amount / risk_per_share)
        if recommended_shares < 1:
            recommended_shares = 1

        total_position_val = round(recommended_shares * entry_price, 2)
        # Cap position value to available capital if not using leverage
        if total_position_val > capital:
            recommended_shares = max(1, int(capital / entry_price))
            total_position_val = round(recommended_shares * entry_price, 2)

        capital_allocated_pct = round((total_position_val / capital) * 100.0, 2)

        potential_profit = None
        rr_ratio = None
        if target_price:
            reward_per_share = abs(target_price - entry_price)
            potential_profit = round(recommended_shares * reward_per_share, 2)
            if risk_per_share > 0:
                rr_ratio = round(reward_per_share / risk_per_share, 2)

        return PositionSizeResponse(
            capital=capital,
            risk_percent=risk_percent,
            max_risk_amount=max_risk_amount,
            risk_per_share=round(risk_per_share, 2),
            recommended_shares=recommended_shares,
            total_position_value=total_position_val,
            capital_allocated_percent=capital_allocated_pct,
            target_price=target_price,
            potential_profit=potential_profit,
            risk_reward_ratio=rr_ratio
        )

risk_engine = RiskEngine()
