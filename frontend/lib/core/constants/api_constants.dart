import 'package:flutter/foundation.dart';

class ApiConstants {
  // Dynamic base URL: defaults to localhost (with adb reverse on mobile), 
  // and dynamically detects the host when served over web to other devices.
  static String get baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
        final scheme = Uri.base.scheme.isNotEmpty ? Uri.base.scheme : 'http';
        return '$scheme://$host:8000/api/v1';
      }
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String get stocks => '$baseUrl/stocks';
  static String get marketStatus => '$baseUrl/market/status';
  static String chart(String symbol, String timeframe) => '$baseUrl/market/$symbol/chart?timeframe=$timeframe';
  static String stockSearch(String query) => '$baseUrl/stocks/search?q=${Uri.encodeComponent(query)}';
  static String prediction(String symbol, String mode) => '$baseUrl/prediction/$symbol?mode=$mode';
  static String predictionHistory(String symbol, String mode) => '$baseUrl/prediction/$symbol/history?mode=$mode';
  static String indicators(String symbol, String timeframe) => '$baseUrl/indicators/$symbol?timeframe=$timeframe';
  static String get riskCalculate => '$baseUrl/risk/calculate-position';
  static String backtest(String symbol, String mode) => '$baseUrl/backtest/$symbol?mode=$mode';
}
