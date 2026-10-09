import 'package:flutter/foundation.dart';
import 'package:trading_master/models/position_size.dart';
import 'package:trading_master/services/prediction_service.dart';

class PositionCalculatorProvider extends ChangeNotifier {
  double _capital = 100000.0;
  double _riskPercent = 1.0;
  double _entryPrice = 1420.0;
  double _stopLoss = 1400.0;
  double? _targetPrice = 1490.0;

  PositionSizeResult? _result;
  bool _isCalculating = false;

  double get capital => _capital;
  double get riskPercent => _riskPercent;
  double get entryPrice => _entryPrice;
  double get stopLoss => _stopLoss;
  double? get targetPrice => _targetPrice;
  PositionSizeResult? get result => _result;
  bool get isCalculating => _isCalculating;

  void updateParameters({
    double? capital,
    double? riskPercent,
    double? entryPrice,
    double? stopLoss,
    double? targetPrice,
  }) {
    if (capital != null) _capital = capital;
    if (riskPercent != null) _riskPercent = riskPercent;
    if (entryPrice != null) _entryPrice = entryPrice;
    if (stopLoss != null) _stopLoss = stopLoss;
    if (targetPrice != null) _targetPrice = targetPrice;
    recalculate();
  }

  Future<void> recalculate() async {
    _isCalculating = true;
    notifyListeners();

    try {
      final res = await predictionService.calculatePositionSize(
        capital: _capital,
        riskPercent: _riskPercent,
        entryPrice: _entryPrice,
        stopLoss: _stopLoss,
        targetPrice: _targetPrice,
      );
      _result = res;
    } catch (_) {
      // Local fallback calculation if offline
      final riskPerShare = (_entryPrice - _stopLoss).abs();
      final maxRisk = _capital * (_riskPercent / 100.0);
      final shares = (riskPerShare > 0) ? (maxRisk / riskPerShare).toInt() : 1;
      final posVal = shares * _entryPrice;
      _result = PositionSizeResult(
        capital: _capital,
        riskPercent: _riskPercent,
        maxRiskAmount: maxRisk,
        riskPerShare: riskPerShare,
        recommendedShares: shares > 0 ? shares : 1,
        totalPositionValue: posVal,
        capitalAllocatedPercent: (posVal / _capital) * 100,
        targetPrice: _targetPrice,
        potentialProfit: _targetPrice != null ? shares * (_targetPrice! - _entryPrice).abs() : null,
        riskRewardRatio: _targetPrice != null && riskPerShare > 0
            ? (_targetPrice! - _entryPrice).abs() / riskPerShare
            : null,
      );
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }
}
