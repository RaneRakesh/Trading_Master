import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/models/indicator.dart';
import 'package:trading_master/models/candle.dart';
import 'package:trading_master/models/backtest.dart';
import 'package:trading_master/services/prediction_service.dart';
import 'package:trading_master/services/market_service.dart';

class PredictionProvider extends ChangeNotifier {
  String _symbol = 'RELIANCE';
  String _mode = 'swing';
  String _timeframe = '1M';

  Prediction? _prediction;
  TechnicalIndicators? _indicators;
  List<Candle> _candles = [];
  BacktestSummary? _backtest;
  PredictionHistory? _predictionHistory;

  bool _isLoading = false;
  String? _errorMessage;

  // Auto-update state (10s interval)
  bool _isAutoUpdateEnabled = true;
  Timer? _autoUpdateTimer;
  Timer? _countdownTimer;
  int _countdown = 10;
  DateTime? _lastUpdated;

  String get symbol => _symbol;
  String get mode => _mode;
  String get timeframe => _timeframe;
  Prediction? get prediction => _prediction;
  TechnicalIndicators? get indicators => _indicators;
  List<Candle> get candles => _candles;
  BacktestSummary? get backtest => _backtest;
  PredictionHistory? get predictionHistory => _predictionHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAutoUpdateEnabled => _isAutoUpdateEnabled;
  int get countdown => _countdown;
  DateTime? get lastUpdated => _lastUpdated;

  Future<void> loadStockDetails(String symbol, String mode) async {
    _symbol = symbol;
    _mode = mode;
    _timeframe = (mode == 'intraday') ? '1D' : ((mode == 'investment') ? '1Y' : '1M');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        _fetchPrediction(),
        _fetchCandles(),
        _fetchIndicators(),
        _fetchBacktest(),
        _fetchPredictionHistory(),
      ]);
      _lastUpdated = DateTime.now();
      _startAutoUpdate();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleAutoUpdate() {
    _isAutoUpdateEnabled = !_isAutoUpdateEnabled;
    if (_isAutoUpdateEnabled) {
      _startAutoUpdate();
    } else {
      _stopAutoUpdate();
    }
    notifyListeners();
  }

  void _startAutoUpdate() {
    _stopAutoUpdate();
    _countdown = 10;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        _countdown--;
        notifyListeners();
      } else {
        _countdown = 10;
      }
    });

    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isAutoUpdateEnabled) return;
      await _autoRefreshSilent();
    });
  }

  void _stopAutoUpdate() {
    _autoUpdateTimer?.cancel();
    _countdownTimer?.cancel();
    _autoUpdateTimer = null;
    _countdownTimer = null;
  }

  Future<void> _autoRefreshSilent() async {
    try {
      await Future.wait([
        _fetchPrediction(),
        _fetchCandles(),
        _fetchIndicators(),
      ]);
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> changeMode(String newMode) async {
    if (_mode == newMode) return;
    _mode = newMode;
    _timeframe = (newMode == 'intraday') ? '1D' : ((newMode == 'investment') ? '1Y' : '1M');
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _fetchPrediction(),
        _fetchCandles(),
        _fetchBacktest(),
        _fetchPredictionHistory(),
      ]);
      _lastUpdated = DateTime.now();
      _startAutoUpdate();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeTimeframe(String newTf) async {
    if (_timeframe == newTf) return;
    _timeframe = newTf;
    notifyListeners();

    try {
      final candles = await marketService.getChartData(_symbol, newTf);
      _candles = candles;
      final ind = await predictionService.getIndicators(_symbol, newTf);
      _indicators = ind;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _fetchPrediction() async {
    final pred = await predictionService.getPrediction(_symbol, _mode);
    _prediction = pred;
  }

  Future<void> _fetchCandles() async {
    final list = await marketService.getChartData(_symbol, _timeframe);
    _candles = list;
  }

  Future<void> _fetchIndicators() async {
    final ind = await predictionService.getIndicators(_symbol, _timeframe);
    _indicators = ind;
  }

  Future<void> _fetchBacktest() async {
    final bt = await predictionService.getBacktest(_symbol, _mode);
    _backtest = bt;
  }

  Future<void> _fetchPredictionHistory() async {
    try {
      final hist = await predictionService.getPredictionHistory(_symbol, _mode);
      _predictionHistory = hist;
    } catch (_) {}
  }

  @override
  void dispose() {
    _stopAutoUpdate();
    super.dispose();
  }
}
