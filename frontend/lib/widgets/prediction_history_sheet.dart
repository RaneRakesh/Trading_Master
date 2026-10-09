import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/models/prediction.dart';

class PredictionHistorySheet extends StatelessWidget {
  final PredictionHistory history;

  const PredictionHistorySheet({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppTheme.bullish, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${history.symbol} Prediction History',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Strategy Audit Log • ${history.mode.toUpperCase()} Mode',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Stats Bar: Win Rate, Profit Factor, Total Samples
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Verified Win Rate',
                  '${history.winRate.toStringAsFixed(1)}%',
                  history.winRate >= 70 ? AppTheme.bullish : AppTheme.accentBlue,
                ),
                Container(width: 1, height: 32, color: AppTheme.cardBorder),
                _buildStatColumn(
                  'Profit Factor',
                  '${history.profitFactor.toStringAsFixed(2)}x',
                  AppTheme.bullish,
                ),
                Container(width: 1, height: 32, color: AppTheme.cardBorder),
                _buildStatColumn(
                  'Predictions Logged',
                  '${history.totalPredictions}',
                  AppTheme.textPrimary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'PAST PREDICTIONS AUDIT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'Target vs Stop Loss',
                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),

          // Predictions List
          Expanded(
            child: history.predictions.isEmpty
                ? const Center(
                    child: Text(
                      'No past predictions recorded yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: history.predictions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = history.predictions[index];
                      return _buildHistoryItemCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItemCard(PredictionHistoryItem item) {
    final isTargetHit = item.result.contains('TARGET');
    final isStopHit = item.result.contains('STOP');
    final resultColor = isTargetHit
        ? AppTheme.bullish
        : (isStopHit ? AppTheme.bearish : AppTheme.neutral);

    final isReturnPos = item.returnPercent >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (item.signal == 'BUY' ? AppTheme.bullish : AppTheme.bearish)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.signal,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.signal == 'BUY' ? AppTheme.bullish : AppTheme.bearish,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.timestamp,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: resultColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  item.result,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: resultColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entry: ${Formatters.formatCurrency(item.entryPrice)}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              Text(
                'Target: ${Formatters.formatCurrency(item.target)}',
                style: const TextStyle(fontSize: 12, color: AppTheme.bullish),
              ),
              Text(
                'Stop: ${Formatters.formatCurrency(item.stopLoss)}',
                style: const TextStyle(fontSize: 12, color: AppTheme.bearish),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Realized Outcome:',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              Text(
                '${isReturnPos ? '+' : ''}${item.returnPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isReturnPos ? AppTheme.bullish : AppTheme.bearish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
