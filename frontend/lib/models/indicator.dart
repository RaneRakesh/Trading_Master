class TechnicalIndicators {
  final String symbol;
  final String timestamp;
  final double rsi;
  final double macd;
  final double macdSignal;
  final double macdHist;
  final double ema9;
  final double ema20;
  final double ema50;
  final double ema200;
  final double sma20;
  final double sma50;
  final double sma200;
  final double atr;
  final double vwap;
  final double bbUpper;
  final double bbMiddle;
  final double bbLower;
  final double volumeRatio;
  final double adx;
  final double plusDi;
  final double minusDi;
  final double stochK;
  final double stochD;
  final double cmf;
  final double? supertrend;
  final int supertrendDir;
  final double volZscore;

  TechnicalIndicators({
    required this.symbol,
    required this.timestamp,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.macdHist,
    required this.ema9,
    required this.ema20,
    required this.ema50,
    required this.ema200,
    required this.sma20,
    required this.sma50,
    required this.sma200,
    required this.atr,
    required this.vwap,
    required this.bbUpper,
    required this.bbMiddle,
    required this.bbLower,
    required this.volumeRatio,
    this.adx = 25.0,
    this.plusDi = 25.0,
    this.minusDi = 25.0,
    this.stochK = 50.0,
    this.stochD = 50.0,
    this.cmf = 0.0,
    this.supertrend,
    this.supertrendDir = 1,
    this.volZscore = 0.0,
  });

  factory TechnicalIndicators.fromJson(Map<String, dynamic> json) {
    return TechnicalIndicators(
      symbol: json['symbol'] ?? '',
      timestamp: json['timestamp'] ?? '',
      rsi: (json['rsi'] as num?)?.toDouble() ?? 50.0,
      macd: (json['macd'] as num?)?.toDouble() ?? 0.0,
      macdSignal: (json['macd_signal'] as num?)?.toDouble() ?? 0.0,
      macdHist: (json['macd_hist'] as num?)?.toDouble() ?? 0.0,
      ema9: (json['ema9'] as num?)?.toDouble() ?? 0.0,
      ema20: (json['ema20'] as num?)?.toDouble() ?? 0.0,
      ema50: (json['ema50'] as num?)?.toDouble() ?? 0.0,
      ema200: (json['ema200'] as num?)?.toDouble() ?? 0.0,
      sma20: (json['sma20'] as num?)?.toDouble() ?? 0.0,
      sma50: (json['sma50'] as num?)?.toDouble() ?? 0.0,
      sma200: (json['sma200'] as num?)?.toDouble() ?? 0.0,
      atr: (json['atr'] as num?)?.toDouble() ?? 0.0,
      vwap: (json['vwap'] as num?)?.toDouble() ?? 0.0,
      bbUpper: (json['bb_upper'] as num?)?.toDouble() ?? 0.0,
      bbMiddle: (json['bb_middle'] as num?)?.toDouble() ?? 0.0,
      bbLower: (json['bb_lower'] as num?)?.toDouble() ?? 0.0,
      volumeRatio: (json['volume_ratio'] as num?)?.toDouble() ?? 1.0,
      adx: (json['adx'] as num?)?.toDouble() ?? 25.0,
      plusDi: (json['plus_di'] as num?)?.toDouble() ?? 25.0,
      minusDi: (json['minus_di'] as num?)?.toDouble() ?? 25.0,
      stochK: (json['stoch_k'] as num?)?.toDouble() ?? 50.0,
      stochD: (json['stoch_d'] as num?)?.toDouble() ?? 50.0,
      cmf: (json['cmf'] as num?)?.toDouble() ?? 0.0,
      supertrend: (json['supertrend'] as num?)?.toDouble(),
      supertrendDir: (json['supertrend_dir'] as num?)?.toInt() ?? 1,
      volZscore: (json['vol_zscore'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
