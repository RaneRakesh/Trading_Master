import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trading_master/models/stock.dart';
import 'package:trading_master/models/market_status.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/services/market_service.dart';
import 'package:trading_master/services/prediction_service.dart';

class MarketProvider extends ChangeNotifier {
  String _selectedMode = 'swing'; // intraday, swing, investment
  String _searchQuery = '';

  // Filter States - Default to 'trending' on start!
  String _selectedFilter = 'trending'; // 'trending', 'all', 'gainers', 'losers', 'buy_signals'
  String _selectedSector = 'All';
  String _selectedSignal = 'All'; // 'All', 'BUY', 'HOLD', 'SELL'
  String _selectedSort = 'trending'; // 'trending', 'change_desc', 'change_asc', 'price_desc', 'price_asc', 'name_asc'

  List<Stock> _stocks = [];
  final Map<String, Prediction> _quickPredictions = {};
  MarketStatus? _marketStatus;

  bool _isLoading = false;
  String? _errorMessage;

  // Auto-update state (10s interval)
  bool _isAutoUpdateEnabled = true;
  Timer? _autoUpdateTimer;
  Timer? _countdownTimer;
  int _refreshCountdown = 10;
  DateTime? _lastUpdated;

  String get selectedMode => _selectedMode;
  String get searchQuery => _searchQuery;
  String get selectedFilter => _selectedFilter;
  String get selectedSector => _selectedSector;
  String get selectedSignal => _selectedSignal;
  String get selectedSort => _selectedSort;
  List<Stock> get stocks => _stocks;
  MarketStatus? get marketStatus => _marketStatus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAutoUpdateEnabled => _isAutoUpdateEnabled;
  int get refreshCountdown => _refreshCountdown;
  DateTime? get lastUpdated => _lastUpdated;

  bool get hasActiveFilters =>
      _selectedFilter != 'trending' ||
      _selectedSector != 'All' ||
      _selectedSignal != 'All' ||
      _selectedSort != 'trending' ||
      _searchQuery.isNotEmpty;

  List<String> get availableSectors {
    final set = <String>{'All'};
    for (final s in _stocks) {
      if (s.sector.isNotEmpty) set.add(s.sector);
    }
    return set.toList();
  }

  List<Stock> get filteredStocks {
    List<Stock> list = List.from(_stocks);

    // 1. Search Query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.symbol.toLowerCase().contains(q) ||
        s.companyName.toLowerCase().contains(q) ||
        s.sector.toLowerCase().contains(q)
      ).toList();
    }

    // 2. Preset Filter (Default: Trending)
    switch (_selectedFilter) {
      case 'trending':
        list = list.where((s) => s.isTrending || s.changePercent.abs() >= 1.2 || s.volume > 1500000).toList();
        break;
      case 'gainers':
        list = list.where((s) => s.change > 0).toList();
        break;
      case 'losers':
        list = list.where((s) => s.change < 0).toList();
        break;
      case 'buy_signals':
        list = list.where((s) {
          final pred = _quickPredictions[s.symbol];
          return pred != null && (pred.signal == 'BUY' || pred.signal == 'ACCUMULATE');
        }).toList();
        break;
      case 'all':
      default:
        break;
    }

    // 3. Sector Filter
    if (_selectedSector != 'All') {
      list = list.where((s) => s.sector.toLowerCase() == _selectedSector.toLowerCase()).toList();
    }

    // 4. AI Signal Filter
    if (_selectedSignal != 'All') {
      list = list.where((s) {
        final pred = _quickPredictions[s.symbol];
        if (pred == null) return false;
        if (_selectedSignal == 'BUY') {
          return pred.signal == 'BUY' || pred.signal == 'ACCUMULATE';
        } else if (_selectedSignal == 'SELL') {
          return pred.signal == 'SELL' || pred.signal == 'AVOID';
        } else {
          return pred.signal == 'HOLD' || pred.signal == 'NEUTRAL' || pred.signal == 'WAIT';
        }
      }).toList();
    }

    // 5. Sorting
    switch (_selectedSort) {
      case 'trending':
        list.sort((a, b) {
          if (a.isTrending && !b.isTrending) return -1;
          if (!a.isTrending && b.isTrending) return 1;
          return b.changePercent.abs().compareTo(a.changePercent.abs());
        });
        break;
      case 'change_desc':
        list.sort((a, b) => b.changePercent.compareTo(a.changePercent));
        break;
      case 'change_asc':
        list.sort((a, b) => a.changePercent.compareTo(b.changePercent));
        break;
      case 'price_desc':
        list.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'price_asc':
        list.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case 'name_asc':
        list.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
    }

    return list;
  }

  Prediction? getQuickPrediction(String symbol) => _quickPredictions[symbol];

  void setMode(String mode) {
    if (_selectedMode != mode) {
      _selectedMode = mode;
      _quickPredictions.clear();
      notifyListeners();
      _fetchQuickPredictions();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    if (query.trim().length >= 2) {
      _searchDynamicBackend(query.trim());
    }
  }

  Future<void> _searchDynamicBackend(String query) async {
    try {
      final results = await marketService.searchStocks(query);
      bool addedAny = false;
      for (final s in results) {
        if (!_stocks.any((existing) => existing.symbol == s.symbol)) {
          _stocks.add(s);
          addedAny = true;
        }
      }
      if (addedAny) {
        notifyListeners();
        _fetchQuickPredictions();
      }
    } catch (_) {}
  }

  void setPresetFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
      _fetchQuickPredictions();
    }
  }

  void setSectorFilter(String sector) {
    if (_selectedSector != sector) {
      _selectedSector = sector;
      notifyListeners();
      _fetchQuickPredictions();
    }
  }

  void setSignalFilter(String signal) {
    if (_selectedSignal != signal) {
      _selectedSignal = signal;
      notifyListeners();
      _fetchQuickPredictions();
    }
  }

  void setSortOrder(String sort) {
    if (_selectedSort != sort) {
      _selectedSort = sort;
      notifyListeners();
    }
  }

  void resetFilters() {
    _selectedFilter = 'trending';
    _selectedSector = 'All';
    _selectedSignal = 'All';
    _selectedSort = 'trending';
    _searchQuery = '';
    notifyListeners();
    _fetchQuickPredictions();
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

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        marketService.getStocks(),
        marketService.getMarketStatus(),
      ]);

      _stocks = results[0] as List<Stock>;
      _marketStatus = results[1] as MarketStatus;
      _lastUpdated = DateTime.now();
      _isLoading = false;
      notifyListeners();

      await _fetchQuickPredictions();
      _startAutoUpdate();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _startAutoUpdate() {
    _stopAutoUpdate();
    _refreshCountdown = 10;

    // Countdown tick every second
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_refreshCountdown > 1) {
        _refreshCountdown--;
        notifyListeners();
      } else {
        _refreshCountdown = 10;
      }
    });

    // Data fetch every 10 seconds
    _autoUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isAutoUpdateEnabled) return;
      await refreshMarketData();
    });
  }

  void _stopAutoUpdate() {
    _autoUpdateTimer?.cancel();
    _countdownTimer?.cancel();
    _autoUpdateTimer = null;
    _countdownTimer = null;
  }

  Future<void> refreshMarketData() async {
    try {
      final results = await Future.wait([
        marketService.getStocks(),
        marketService.getMarketStatus(),
      ]);

      _stocks = results[0] as List<Stock>;
      _marketStatus = results[1] as MarketStatus;
      _lastUpdated = DateTime.now();
      notifyListeners();

      await _fetchQuickPredictions();
    } catch (_) {}
  }

  Future<void> _fetchQuickPredictions() async {
    final targets = filteredStocks.isNotEmpty ? filteredStocks.take(12).toList() : _stocks.take(12).toList();
    for (final s in targets) {
      if (_quickPredictions.containsKey(s.symbol) && _quickPredictions[s.symbol]?.mode == _selectedMode) {
        continue;
      }
      try {
        final pred = await predictionService.getPrediction(s.symbol, _selectedMode);
        _quickPredictions[s.symbol] = pred;
        notifyListeners();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _stopAutoUpdate();
    super.dispose();
  }
}
