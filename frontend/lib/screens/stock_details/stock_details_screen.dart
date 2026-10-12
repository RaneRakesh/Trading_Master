import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/providers/prediction_provider.dart';
import 'package:trading_master/screens/backtest/backtest_screen.dart';
import 'package:trading_master/widgets/stock_chart.dart';
import 'package:trading_master/widgets/prediction_card.dart';
import 'package:trading_master/widgets/indicator_card.dart';
import 'package:trading_master/widgets/investment_score_card.dart';
import 'package:trading_master/widgets/risk_calculator_dialog.dart';
import 'package:trading_master/widgets/prediction_history_sheet.dart';

class StockDetailsScreen extends StatefulWidget {
  final String symbol;
  final String initialMode;

  const StockDetailsScreen({
    super.key,
    required this.symbol,
    this.initialMode = 'swing',
  });

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().loadStockDetails(widget.symbol, widget.initialMode);
    });
  }

  void _openRiskCalculator(double price, double stop, double target) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RiskCalculatorDialog(
        currentPrice: price,
        defaultStopLoss: stop,
        defaultTarget: target,
      ),
    );
  }

  void _openPredictionHistory(PredictionHistory? history) {
    if (history == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PredictionHistorySheet(history: history),
    );
  }

  @override
  Widget build(BuildContext context) {
    final predProv = context.watch<PredictionProvider>();
    final prediction = predProv.prediction;
    final indicators = predProv.indicators;
    final isBull = prediction?.isBullish ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.symbol),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historical Backtest',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BacktestScreen(
                    symbol: widget.symbol,
                    mode: predProv.mode,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => predProv.loadStockDetails(widget.symbol, predProv.mode),
          ),
        ],
      ),
      body: predProv.isLoading && prediction == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.bullish))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Stock Price & Change Summary Header
                if (prediction != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.symbol,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AI Decision-Support System',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(prediction.currentPrice),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          Text(
                            prediction.direction,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isBull ? AppTheme.bullish : AppTheme.bearish,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 2. Mode Selector Pill Row (Intraday / Swing / Investment)
                  _buildModePills(predProv),

                  const SizedBox(height: 16),

                  // 3. Interactive Candlestick / Line Chart
                  StockChart(
                    candles: predProv.candles,
                    activeTimeframe: predProv.timeframe,
                    onTimeframeChanged: (tf) => predProv.changeTimeframe(tf),
                  ),

                  const SizedBox(height: 16),

                  // 4. AI Prediction Card
                  PredictionCard(
                    prediction: prediction,
                    onOpenRiskCalculator: () => _openRiskCalculator(
                      prediction.currentPrice,
                      prediction.stopLoss,
                      prediction.target,
                    ),
                    onViewHistory: () => _openPredictionHistory(predProv.predictionHistory),
                  ),

                  const SizedBox(height: 16),

                  // 5. Investment Fundamental Scorecard (if Investment mode)
                  if (prediction.investmentScore != null && predProv.mode == 'investment') ...[
                    InvestmentScoreCard(score: prediction.investmentScore!),
                    const SizedBox(height: 16),
                  ],

                  // 6. Technical Indicators Grid
                  if (indicators != null) ...[
                    IndicatorCard(
                      indicators: indicators,
                      currentPrice: prediction.currentPrice,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 7. Strategy Rule-Set Backtest Simulation
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.science_outlined, size: 16, color: AppTheme.accentBlue),
                            SizedBox(width: 6),
                            Text(
                              'STRATEGY SIMULATION (MULTI-YEAR)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.6,
                                color: AppTheme.accentBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Test how this ${predProv.mode.toUpperCase()} rule-set performed over years of historical candle data to verify its statistical edge (not personal broker trades).',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BacktestScreen(
                                    symbol: widget.symbol,
                                    mode: predProv.mode,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.assessment, size: 16),
                            label: Text('Open ${predProv.mode.toUpperCase()} Strategy Backtest'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surface,
                              foregroundColor: AppTheme.textPrimary,
                              side: const BorderSide(color: AppTheme.accentBlue),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ],
            ),
    );
  }

  Widget _buildModePills(PredictionProvider prov) {
    final modes = [
      {'id': 'intraday', 'label': 'Intraday (15-120m)'},
      {'id': 'swing', 'label': 'Swing (5 Days)'},
      {'id': 'investment', 'label': 'Investment (3m-Years)'},
    ];

    return Row(
      children: modes.map((m) {
        final isSelected = prov.mode == m['id'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => prov.changeMode(m['id'] as String),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accentBlue.withValues(alpha: 0.2) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppTheme.accentBlue : AppTheme.cardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    m['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
