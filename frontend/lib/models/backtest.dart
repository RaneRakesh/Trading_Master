class BacktestTrade {
  final String entryDate;
  final String exitDate;
  final String type;
  final double entryPrice;
  final double exitPrice;
  final double pnl;
  final double returnPercent;
  final String reason;

  BacktestTrade({
    required this.entryDate,
    required this.exitDate,
    required this.type,
    required this.entryPrice,
    required this.exitPrice,
    required this.pnl,
    required this.returnPercent,
    required this.reason,
  });

  factory BacktestTrade.fromJson(Map<String, dynamic> json) {
    return BacktestTrade(
      entryDate: json['entry_date'] ?? '',
      exitDate: json['exit_date'] ?? '',
      type: json['type'] ?? 'BUY',
      entryPrice: (json['entry_price'] as num?)?.toDouble() ?? 0.0,
      exitPrice: (json['exit_price'] as num?)?.toDouble() ?? 0.0,
      pnl: (json['pnl'] as num?)?.toDouble() ?? 0.0,
      returnPercent: (json['return_percent'] as num?)?.toDouble() ?? 0.0,
      reason: json['reason'] ?? '',
    );
  }
}

class BacktestSummary {
  final String symbol;
  final String mode;
  final double initialCapital;
  final double finalCapital;
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double winRate;
  final double totalReturnPercent;
  final double profitFactor;
  final double maxDrawdownPercent;
  final List<BacktestTrade> trades;

  BacktestSummary({
    required this.symbol,
    required this.mode,
    required this.initialCapital,
    required this.finalCapital,
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.winRate,
    required this.totalReturnPercent,
    required this.profitFactor,
    required this.maxDrawdownPercent,
    required this.trades,
  });

  factory BacktestSummary.fromJson(Map<String, dynamic> json) {
    return BacktestSummary(
      symbol: json['symbol'] ?? '',
      mode: json['mode'] ?? 'swing',
      initialCapital: (json['initial_capital'] as num?)?.toDouble() ?? 100000.0,
      finalCapital: (json['final_capital'] as num?)?.toDouble() ?? 100000.0,
      totalTrades: (json['total_trades'] as num?)?.toInt() ?? 0,
      winningTrades: (json['winning_trades'] as num?)?.toInt() ?? 0,
      losingTrades: (json['losing_trades'] as num?)?.toInt() ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      totalReturnPercent: (json['total_return_percent'] as num?)?.toDouble() ?? 0.0,
      profitFactor: (json['profit_factor'] as num?)?.toDouble() ?? 1.0,
      maxDrawdownPercent: (json['max_drawdown_percent'] as num?)?.toDouble() ?? 0.0,
      trades: (json['trades'] as List<dynamic>?)
              ?.map((e) => BacktestTrade.fromJson(e))
              .toList() ??
          [],
    );
  }
}
