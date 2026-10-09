class MarketStatus {
  final String nseStatus;
  final double nifty50Price;
  final double nifty50Change;
  final double nifty50Percent;
  final double bankniftyPrice;
  final double bankniftyChange;
  final double bankniftyPercent;
  final String regime;
  final String regimeDescription;
  final String timestamp;

  MarketStatus({
    required this.nseStatus,
    required this.nifty50Price,
    required this.nifty50Change,
    required this.nifty50Percent,
    required this.bankniftyPrice,
    required this.bankniftyChange,
    required this.bankniftyPercent,
    required this.regime,
    required this.regimeDescription,
    required this.timestamp,
  });

  factory MarketStatus.fromJson(Map<String, dynamic> json) {
    return MarketStatus(
      nseStatus: json['nse_status'] ?? 'CLOSED',
      nifty50Price: (json['nifty50_price'] as num?)?.toDouble() ?? 0.0,
      nifty50Change: (json['nifty50_change'] as num?)?.toDouble() ?? 0.0,
      nifty50Percent: (json['nifty50_percent'] as num?)?.toDouble() ?? 0.0,
      bankniftyPrice: (json['banknifty_price'] as num?)?.toDouble() ?? 0.0,
      bankniftyChange: (json['banknifty_change'] as num?)?.toDouble() ?? 0.0,
      bankniftyPercent: (json['banknifty_percent'] as num?)?.toDouble() ?? 0.0,
      regime: json['regime'] ?? 'Normal',
      regimeDescription: json['regime_description'] ?? '',
      timestamp: json['timestamp'] ?? '',
    );
  }
}
