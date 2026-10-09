class PositionSizeResult {
  final double capital;
  final double riskPercent;
  final double maxRiskAmount;
  final double riskPerShare;
  final int recommendedShares;
  final double totalPositionValue;
  final double capitalAllocatedPercent;
  final double? targetPrice;
  final double? potentialProfit;
  final double? riskRewardRatio;

  PositionSizeResult({
    required this.capital,
    required this.riskPercent,
    required this.maxRiskAmount,
    required this.riskPerShare,
    required this.recommendedShares,
    required this.totalPositionValue,
    required this.capitalAllocatedPercent,
    this.targetPrice,
    this.potentialProfit,
    this.riskRewardRatio,
  });

  factory PositionSizeResult.fromJson(Map<String, dynamic> json) {
    return PositionSizeResult(
      capital: (json['capital'] as num?)?.toDouble() ?? 100000.0,
      riskPercent: (json['risk_percent'] as num?)?.toDouble() ?? 1.0,
      maxRiskAmount: (json['max_risk_amount'] as num?)?.toDouble() ?? 1000.0,
      riskPerShare: (json['risk_per_share'] as num?)?.toDouble() ?? 0.0,
      recommendedShares: (json['recommended_shares'] as num?)?.toInt() ?? 0,
      totalPositionValue: (json['total_position_value'] as num?)?.toDouble() ?? 0.0,
      capitalAllocatedPercent: (json['capital_allocated_percent'] as num?)?.toDouble() ?? 0.0,
      targetPrice: (json['target_price'] as num?)?.toDouble(),
      potentialProfit: (json['potential_profit'] as num?)?.toDouble(),
      riskRewardRatio: (json['risk_reward_ratio'] as num?)?.toDouble(),
    );
  }
}
