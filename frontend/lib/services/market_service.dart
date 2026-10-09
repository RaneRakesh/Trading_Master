import 'package:trading_master/core/constants/api_constants.dart';
import 'package:trading_master/models/stock.dart';
import 'package:trading_master/models/candle.dart';
import 'package:trading_master/models/market_status.dart';
import 'package:trading_master/services/api_service.dart';

class MarketService {
  Future<List<Stock>> getStocks() async {
    final data = await apiService.get(ApiConstants.stocks);
    if (data is List) {
      return data.map((item) => Stock.fromJson(item)).toList();
    }
    return [];
  }

  Future<MarketStatus> getMarketStatus() async {
    final data = await apiService.get(ApiConstants.marketStatus);
    return MarketStatus.fromJson(data);
  }

  Future<List<Candle>> getChartData(String symbol, String timeframe) async {
    final data = await apiService.get(ApiConstants.chart(symbol, timeframe));
    final candlesJson = data['candles'] as List<dynamic>? ?? [];
    return candlesJson.map((c) => Candle.fromJson(c)).toList();
  }

  Future<List<Stock>> searchStocks(String query) async {
    final data = await apiService.get(ApiConstants.stockSearch(query));
    if (data is List) {
      return data.map((item) => Stock.fromJson(item)).toList();
    }
    return [];
  }
}

final marketService = MarketService();
