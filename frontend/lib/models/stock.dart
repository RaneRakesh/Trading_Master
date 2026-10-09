class Stock {
  final String symbol;
  final String companyName;
  final String exchange;
  final String sector;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final String timestamp;
  final bool isTrending;

  Stock({
    required this.symbol,
    required this.companyName,
    required this.exchange,
    required this.sector,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.timestamp,
    this.isTrending = false,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      companyName: json['company_name'] ?? '',
      exchange: json['exchange'] ?? 'NSE',
      sector: json['sector'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['change_percent'] as num?)?.toDouble() ?? 0.0,
      open: (json['open'] as num?)?.toDouble() ?? 0.0,
      high: (json['high'] as num?)?.toDouble() ?? 0.0,
      low: (json['low'] as num?)?.toDouble() ?? 0.0,
      close: (json['close'] as num?)?.toDouble() ?? 0.0,
      volume: (json['volume'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] ?? '',
      isTrending: json['is_trending'] ?? false,
    );
  }
}
