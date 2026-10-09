import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/providers/market_provider.dart';

class StockFilterSheet extends StatelessWidget {
  final MarketProvider market;

  const StockFilterSheet({super.key, required this.market});

  static void show(BuildContext context, MarketProvider market) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StockFilterSheet(market: market),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presets = [
      {'id': 'trending', 'label': '🔥 Trending', 'desc': 'High momentum & active leaders'},
      {'id': 'all', 'label': '🌟 All Stocks', 'desc': 'Complete market catalog (60+ stocks)'},
      {'id': 'gainers', 'label': '🚀 Top Gainers', 'desc': 'Equities in positive territory'},
      {'id': 'losers', 'label': '🔻 Top Losers', 'desc': 'Equities with negative change'},
      {'id': 'buy_signals', 'label': '⭐ Buy Signals', 'desc': 'AI BUY & ACCUMULATE recommendations'},
    ];

    final sortOptions = [
      {'id': 'trending', 'label': '🔥 Trending Momentum'},
      {'id': 'change_desc', 'label': '🚀 % Change (High to Low)'},
      {'id': 'change_asc', 'label': '🔻 % Change (Low to High)'},
      {'id': 'price_desc', 'label': '💰 Price (High to Low)'},
      {'id': 'price_asc', 'label': '🪙 Price (Low to High)'},
      {'id': 'name_asc', 'label': '🔤 Symbol (A to Z)'},
    ];

    final signalOptions = ['All', 'BUY', 'HOLD', 'SELL'];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.cardBorder, width: 1.5),
          left: BorderSide(color: AppTheme.cardBorder),
          right: BorderSide(color: AppTheme.cardBorder),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune, color: AppTheme.accentBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter & Sort Market',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Filter by trends, sector, signal & sorting',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    market.resetFilters();
                  },
                  child: const Text('Reset', style: TextStyle(color: AppTheme.accentBlue, fontSize: 13)),
                ),
              ],
            ),
          ),

          const Divider(color: AppTheme.cardBorder, height: 1),

          // Scrollable Filter Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // 1. Market Views & Presets
                const Text(
                  'MARKET PRESET VIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: presets.map((p) {
                    final isSelected = market.selectedFilter == p['id'];
                    return ChoiceChip(
                      label: Text(p['label']!),
                      selected: isSelected,
                      onSelected: (_) => market.setPresetFilter(p['id']!),
                      selectedColor: AppTheme.accentBlue.withValues(alpha: 0.25),
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.accentBlue : AppTheme.textPrimary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.accentBlue : AppTheme.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 2. Sector Filter
                const Text(
                  'SECTOR FILTER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: market.availableSectors.map((sector) {
                    final isSelected = market.selectedSector == sector;
                    return ChoiceChip(
                      label: Text(sector),
                      selected: isSelected,
                      onSelected: (_) => market.setSectorFilter(sector),
                      selectedColor: AppTheme.bullish.withValues(alpha: 0.2),
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.bullish : AppTheme.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.bullish : AppTheme.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 3. AI Signal Filter
                const Text(
                  'AI RECOMMENDATION SIGNAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: signalOptions.map((sig) {
                    final isSelected = market.selectedSignal == sig;
                    Color sigColor = AppTheme.textPrimary;
                    if (sig == 'BUY') sigColor = AppTheme.bullish;
                    if (sig == 'SELL') sigColor = AppTheme.bearish;
                    if (sig == 'HOLD') sigColor = AppTheme.neutral;

                    return ChoiceChip(
                      label: Text(sig == 'All' ? 'All Signals' : '$sig Signal'),
                      selected: isSelected,
                      onSelected: (_) => market.setSignalFilter(sig),
                      selectedColor: sigColor.withValues(alpha: 0.2),
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? sigColor : AppTheme.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? sigColor : AppTheme.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // 4. Sort By
                const Text(
                  'SORT ORDER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sortOptions.map((s) {
                    final isSelected = market.selectedSort == s['id'];
                    return ChoiceChip(
                      label: Text(s['label']!),
                      selected: isSelected,
                      onSelected: (_) => market.setSortOrder(s['id']!),
                      selectedColor: AppTheme.accentBlue.withValues(alpha: 0.25),
                      backgroundColor: AppTheme.surface,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.accentBlue : AppTheme.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.accentBlue : AppTheme.cardBorder,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Footer with Count & Apply
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${market.filteredStocks.length} Stocks Matching',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        market.selectedFilter == 'trending'
                            ? 'Default: Trending momentum'
                            : 'Filter active: ${market.selectedFilter}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bullish,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
