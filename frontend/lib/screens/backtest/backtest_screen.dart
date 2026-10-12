import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/models/backtest.dart';
import 'package:trading_master/services/prediction_service.dart';

class BacktestScreen extends StatefulWidget {
  final String symbol;
  final String mode;

  const BacktestScreen({
    super.key,
    required this.symbol,
    required this.mode,
  });

  @override
  State<BacktestScreen> createState() => _BacktestScreenState();
}

class _BacktestScreenState extends State<BacktestScreen> {
  BacktestSummary? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await predictionService.getBacktest(widget.symbol, widget.mode);
      setState(() {
        _summary = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.symbol} — ${widget.mode.toUpperCase()} Backtest'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.bullish))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Error: $_error', style: const TextStyle(color: AppTheme.bearish)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : _summary == null
                  ? const Center(child: Text('No backtest results available'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Explainer Banner: What is a strategy backtest?
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.science_outlined, size: 20, color: AppTheme.accentBlue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Algorithm Backtest Simulation',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'This simulates how Trading Master\'s mathematical ${widget.mode.toUpperCase()} rule-set performed over historical price bars on ${widget.symbol}. It evaluates the algorithm\'s long-term statistical profitability (not your personal broker account trades).',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 1. Performance Overview Card
                        _buildOverviewCard(_summary!),

                        const SizedBox(height: 16),

                        // 2. Performance Metrics Grid
                        _buildMetricsGrid(_summary!),

                        const SizedBox(height: 20),

                        // 3. Trade History Title
                        const Text(
                          'Simulated Algorithmic Trade Log (Chronological)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 10),

                        // 4. Trades Table
                        ..._summary!.trades.reversed.map((t) => _buildTradeItem(t)),

                        const SizedBox(height: 24),
                      ],
                    ),
    );
  }

  Widget _buildOverviewCard(BacktestSummary s) {
    final isProfitable = s.totalReturnPercent >= 0;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Simulated Return', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatPercent(s.totalReturnPercent),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isProfitable ? AppTheme.bullish : AppTheme.bearish,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Final Capital', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(s.finalCapital),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.cardBorder),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Initial Capital: ${Formatters.formatCurrency(s.initialCapital)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              Text('Total Trades: ${s.totalTrades}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BacktestSummary s) {
    return Row(
      children: [
        Expanded(child: _buildMetricPill('Win Rate', '${s.winRate.toStringAsFixed(1)}%', AppTheme.bullish)),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricPill('Profit Factor', s.profitFactor.toStringAsFixed(2), AppTheme.accentBlue)),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricPill('Max Drawdown', '${s.maxDrawdownPercent.toStringAsFixed(1)}%', AppTheme.bearish)),
      ],
    );
  }

  Widget _buildMetricPill(String label, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(val, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTradeItem(BacktestTrade t) {
    final isWin = t.pnl > 0;
    final color = isWin ? AppTheme.bullish : AppTheme.bearish;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      t.reason,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Entry: ₹${t.entryPrice.toStringAsFixed(1)} → Exit: ₹${t.exitPrice.toStringAsFixed(1)}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${t.entryDate} to ${t.exitDate}',
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isWin ? "+" : ""}${Formatters.formatCurrency(t.pnl)}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                Formatters.formatPercent(t.returnPercent),
                style: TextStyle(fontSize: 10, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
