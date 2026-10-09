import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/providers/market_provider.dart';
import 'package:trading_master/screens/stock_details/stock_details_screen.dart';
import 'package:trading_master/widgets/stock_filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final status = market.marketStatus;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppTheme.bullish.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.trending_up, color: AppTheme.bullish, size: 20),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Trading Master AI',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          // Live Auto-Update Badge & Toggle
          Center(
            child: InkWell(
              onTap: () => market.toggleAutoUpdate(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: market.isAutoUpdateEnabled
                      ? AppTheme.bullish.withValues(alpha: 0.15)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: market.isAutoUpdateEnabled
                        ? AppTheme.bullish.withValues(alpha: 0.5)
                        : AppTheme.cardBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: market.isAutoUpdateEnabled ? AppTheme.bullish : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      market.isAutoUpdateEnabled
                          ? 'AUTO 10s (${market.refreshCountdown}s)'
                          : 'PAUSED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: market.isAutoUpdateEnabled ? AppTheme.bullish : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: () => market.refreshMarketData(),
          ),
        ],
      ),
      body: market.isLoading && market.stocks.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppTheme.bullish))
          : RefreshIndicator(
              onRefresh: () => market.initialize(),
              color: AppTheme.bullish,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  // 1. Market Status & Regime Banner
                  if (status != null) _buildMarketStatusBanner(status),

                  const SizedBox(height: 16),

                  // 2. Search & Filter Bar (Filter Button side-by-side with Search)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => market.setSearchQuery(val),
                          decoration: InputDecoration(
                            hintText: 'Search 60+ stocks by symbol, name...',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      market.setSearchQuery('');
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter button on the side of search
                      _buildFilterButton(market),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2b. Quick Filter Preset Chips (Default: Trending)
                  _buildQuickFilterChips(market),

                  const SizedBox(height: 16),

                  // 3. Mode Selector Tabs (Intraday, Swing, Investment)
                  _buildModeSelector(market),

                  const SizedBox(height: 18),

                  // 4. Section Header with Active Filter Indication
                  _buildSectionHeader(market),

                  const SizedBox(height: 10),

                  // 5. Stocks List or Empty State
                  if (market.filteredStocks.isEmpty)
                    _buildEmptyState(market)
                  else
                    ...market.filteredStocks.map((stock) {
                      final pred = market.getQuickPrediction(stock.symbol);
                      return _buildStockSignalCard(stock, pred, market.selectedMode);
                    }),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildMarketStatusBanner(dynamic status) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: status.nseStatus == 'OPEN' ? AppTheme.bullish : AppTheme.neutral,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'NSE Market ${status.nseStatus}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status.nseStatus == 'OPEN' ? AppTheme.bullish : AppTheme.neutral,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.regime,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NIFTY 50', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(status.nifty50Price),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      '${Formatters.formatCurrency(status.nifty50Change)} (${Formatters.formatPercent(status.nifty50Percent)})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.bullish),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 35, color: AppTheme.cardBorder),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BANK NIFTY', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatCurrency(status.bankniftyPrice),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    Text(
                      '${Formatters.formatCurrency(status.bankniftyChange)} (${Formatters.formatPercent(status.bankniftyPercent)})',
                      style: const TextStyle(fontSize: 11, color: AppTheme.bullish),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(MarketProvider market) {
    final modes = [
      {'id': 'intraday', 'label': 'Intraday', 'sub': '15m–120m', 'icon': Icons.flash_on},
      {'id': 'swing', 'label': 'Swing', 'sub': '2–20 Days', 'icon': Icons.swap_vert},
      {'id': 'investment', 'label': 'Investment', 'sub': '3m–Years', 'icon': Icons.account_balance},
    ];

    return Row(
      children: modes.map((m) {
        final isSelected = market.selectedMode == m['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => market.setMode(m['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentBlue.withValues(alpha: 0.2) : AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentBlue : AppTheme.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 20,
                      color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      m['sub'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockSignalCard(dynamic stock, dynamic pred, String mode) {
    final isPos = stock.change >= 0;
    final changeColor = isPos ? AppTheme.bullish : AppTheme.bearish;

    final signal = pred?.signal ?? 'ANALYZING';
    final confidence = pred != null ? (pred.confidence * 100).round() : null;

    final signalColor = (signal == 'BUY' || signal == 'ACCUMULATE')
        ? AppTheme.bullish
        : ((signal == 'SELL' || signal == 'AVOID') ? AppTheme.bearish : AppTheme.neutral);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StockDetailsScreen(
                symbol: stock.symbol,
                initialMode: mode,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Left: Symbol & Sector
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stock.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stock.sector,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

              // Middle: Current Price & 24h Change
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.formatCurrency(stock.currentPrice),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatPercent(stock.changePercent),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: changeColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right: AI Signal & Confidence
              Container(
                width: 82,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: signalColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: signalColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text(
                      signal,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: signalColor,
                      ),
                    ),
                    if (confidence != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '$confidence%',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: signalColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(MarketProvider market) {
    final hasActive = market.hasActiveFilters;
    return InkWell(
      onTap: () => StockFilterSheet.show(context, market),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: hasActive ? AppTheme.accentBlue.withValues(alpha: 0.15) : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasActive ? AppTheme.accentBlue : AppTheme.cardBorder,
            width: hasActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 20,
              color: hasActive ? AppTheme.accentBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Filter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: hasActive ? AppTheme.accentBlue : AppTheme.textPrimary,
              ),
            ),
            if (hasActive) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppTheme.accentBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips(MarketProvider market) {
    final chips = [
      {'type': 'preset', 'id': 'trending', 'label': '🔥 Trending', 'default': true},
      {'type': 'preset', 'id': 'all', 'label': '🌟 All Stocks (${market.stocks.length})'},
      {'type': 'preset', 'id': 'gainers', 'label': '🚀 Top Gainers'},
      {'type': 'preset', 'id': 'losers', 'label': '🔻 Top Losers'},
      {'type': 'preset', 'id': 'buy_signals', 'label': '⭐ Buy Signals'},
      {'type': 'sector', 'id': 'Banking & Financials', 'label': '🏦 Banking'},
      {'type': 'sector', 'id': 'Information Technology', 'label': '💻 IT'},
      {'type': 'sector', 'id': 'Automotive', 'label': '🚗 Auto'},
      {'type': 'sector', 'id': 'Energy / Conglomerate', 'label': '⚡ Energy'},
      {'type': 'sector', 'id': 'Pharma & Healthcare', 'label': '💊 Pharma'},
      {'type': 'sector', 'id': 'Metals & Mining', 'label': '🧱 Metals'},
      {'type': 'sector', 'id': 'Defence & Aerospace', 'label': '🛡️ Defence'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((c) {
          final isPreset = c['type'] == 'preset';
          final isSelected = isPreset
              ? (market.selectedFilter == c['id'] && market.selectedSector == 'All')
              : (market.selectedSector == c['id']);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(c['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                if (isPreset) {
                  market.setPresetFilter(c['id'] as String);
                  market.setSectorFilter('All');
                } else {
                  market.setPresetFilter('all');
                  market.setSectorFilter(c['id'] as String);
                }
              },
              selectedColor: AppTheme.accentBlue.withValues(alpha: 0.25),
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.accentBlue : AppTheme.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.accentBlue : AppTheme.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(MarketProvider market) {
    String title = '🔥 Trending Stocks';
    bool isDefault = market.selectedFilter == 'trending' && market.selectedSector == 'All';

    if (market.selectedSector != 'All') {
      title = '${market.selectedSector} Stocks';
    } else if (market.selectedFilter == 'all') {
      title = '🌟 All Market Stocks';
    } else if (market.selectedFilter == 'gainers') {
      title = '🚀 Top Gainers';
    } else if (market.selectedFilter == 'losers') {
      title = '🔻 Top Losers';
    } else if (market.selectedFilter == 'buy_signals') {
      title = '⭐ Buy Signals';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.bullish.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEFAULT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bullish,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        Text(
          '${market.filteredStocks.length} Stocks',
          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildEmptyState(MarketProvider market) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.filter_alt_off_rounded, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 12),
          const Text(
            'No Stocks Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'No instruments match your active search or filter criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => market.resetFilters(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset to Trending'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bullish,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
