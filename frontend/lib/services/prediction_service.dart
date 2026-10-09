import 'package:trading_master/core/constants/api_constants.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/models/indicator.dart';
import 'package:trading_master/models/position_size.dart';
import 'package:trading_master/models/backtest.dart';
import 'package:trading_master/services/api_service.dart';

class PredictionService {
  Future<Prediction> getPrediction(String symbol, String mode) async {
    final data = await apiService.get(ApiConstants.prediction(symbol, mode));
    return Prediction.fromJson(data);
  }

  Future<TechnicalIndicators> getIndicators(String symbol, String timeframe) async {
    final data = await apiService.get(ApiConstants.indicators(symbol, timeframe));
    return TechnicalIndicators.fromJson(data);
  }

  Future<PositionSizeResult> calculatePositionSize({
    required double capital,
    required double riskPercent,
    required double entryPrice,
    required double stopLoss,
    double? targetPrice,
  }) async {
    final data = await apiService.post(ApiConstants.riskCalculate, {
      'capital': capital,
      'risk_percent': riskPercent,
      'entry_price': entryPrice,
      'stop_loss': stopLoss,
      'target_price': ?targetPrice,
    });
    return PositionSizeResult.fromJson(data);
  }

  Future<BacktestSummary> getBacktest(String symbol, String mode) async {
    final data = await apiService.get(ApiConstants.backtest(symbol, mode));
    return BacktestSummary.fromJson(data);
  }

  Future<PredictionHistory> getPredictionHistory(String symbol, String mode) async {
    final data = await apiService.get(ApiConstants.predictionHistory(symbol, mode));
    return PredictionHistory.fromJson(data);
  }
}

final predictionService = PredictionService();
