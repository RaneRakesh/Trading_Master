import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/widgets/confidence_meter.dart';

class PredictionCard extends StatelessWidget {
  final Prediction prediction;
  final VoidCallback onOpenRiskCalculator;
  final VoidCallback? onViewHistory;

  const PredictionCard({
    super.key,
    required this.prediction,
    required this.onOpenRiskCalculator,
    this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final isBull = prediction.isBullish;
    final isBear = prediction.isBearish;
    final accentColor = isBull
        ? AppTheme.bullish
        : (isBear ? AppTheme.bearish : AppTheme.neutral);

    final winRate = prediction.historicalWinRate ?? prediction.accuracyRate;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Mode tag, Signal status pill, Verified Win Rate %
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${prediction.mode.toUpperCase()} MODE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Audited Win Rate Chip
                  Tooltip(
                    message: 'Click to view Trading Master AI\'s audited signal track record for this stock',
                    child: InkWell(
                      onTap: onViewHistory,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.bullish.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.bullish.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_outlined, size: 12, color: AppTheme.bullish),
                            const SizedBox(width: 4),
                            Text(
                              '${winRate.toStringAsFixed(1)}% AI Win Rate',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                color: AppTheme.bullish,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  prediction.signal,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Main Prediction Row: Target, Stop Loss, and Confidence Meter
          Row(
            children: [
              // Confidence gauge
              ConfidenceMeter(
                confidence: prediction.confidence,
                direction: prediction.direction,
                size: 96,
              ),

              const SizedBox(width: 18),

              // Price targets grid
              Expanded(
                child: Column(
                  children: [
                    _buildMetricRow(
                      'Potential Target',
                      Formatters.formatCurrency(prediction.target),
                      AppTheme.bullish,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'Invalidation (Stop Loss)',
                      Formatters.formatCurrency(prediction.stopLoss),
                      AppTheme.bearish,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'Risk : Reward',
                      '1 : ${prediction.riskRewardRatio.toStringAsFixed(1)}',
                      AppTheme.textPrimary,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricRow(
                      'Horizon',
                      prediction.horizon,
                      AppTheme.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // QUANTITATIVE STRATEGY STUDY
          if (prediction.strategyStudy != null) ...[
            _buildStrategyStudyCard(prediction.strategyStudy!),
            const SizedBox(height: 14),
          ],

          // LIVE DYNAMIC NEWS & WEB CATALYSTS STUDY
          if (prediction.newsStudy != null) ...[
            _buildNewsStudyCard(prediction.newsStudy!),
            const SizedBox(height: 14),
          ],

          // DUAL-MODEL VALIDATION & ASSURANCE SECTION
          _buildDualModelAssurance(context),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder),
          const SizedBox(height: 12),

          // Transparent Reasoning ("Why BUY/SELL?")
          Text(
            'Why ${prediction.signal}?',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...prediction.reasons.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓ ', style: TextStyle(color: AppTheme.bullish, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        r,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),

          // Risk Warnings
          if (prediction.riskFactors.isNotEmpty) ...[
            const Text(
              'Risk Factors:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutral,
              ),
            ),
            const SizedBox(height: 6),
            ...prediction.riskFactors.map((rf) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠ ', style: TextStyle(color: AppTheme.neutral, fontSize: 12)),
                      Expanded(
                        child: Text(
                          rf,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
          ],

          // Action 1: Open Audited AI Prediction Track Record
          if (onViewHistory != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onViewHistory,
                icon: const Icon(Icons.analytics_outlined, size: 18, color: AppTheme.bullish),
                label: Text(
                  'View AI Signal Track Record (${winRate.toStringAsFixed(1)}% Win Rate)',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.bullish),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surface,
                  side: const BorderSide(color: AppTheme.bullish),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Action 2: Open Position Sizer & Risk Management
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenRiskCalculator,
              icon: const Icon(Icons.calculate, size: 18, color: AppTheme.accentBlue),
              label: const Text(
                'Position Sizing & Risk Calculator (Protect Capital)',
                style: TextStyle(color: AppTheme.accentBlue, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.accentBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Dynamic model prediction synthesized with live internet study.',
              style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyStudyCard(StrategyStudy study) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.psychology, size: 16, color: AppTheme.accentBlue),
                  SizedBox(width: 6),
                  Text(
                    'QUANTITATIVE STRATEGY STUDY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppTheme.accentBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  study.timeframePlan,
                  style: const TextStyle(fontSize: 10, color: AppTheme.accentBlue, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            study.strategyName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            study.strategyDescription,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 8),
          const Text(
            'Strategy Confluences:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 4),
          ...study.keyConfluences.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚡ ', style: TextStyle(fontSize: 11, color: AppTheme.accentBlue)),
                  Expanded(
                    child: Text(
                      c,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 13, color: AppTheme.bullish),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Risk Rule: ${study.riskManagementRule}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.bullish, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Internet Study Source: ${study.internetStudySource}',
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsStudyCard(NewsStudy news) {
    final isBull = news.sentimentLabel == 'BULLISH';
    final isBear = news.sentimentLabel == 'BEARISH';
    final sentColor = isBull ? AppTheme.bullish : (isBear ? AppTheme.bearish : AppTheme.neutral);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sentColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.newspaper, size: 16, color: AppTheme.textPrimary),
                  SizedBox(width: 6),
                  Text(
                    'LIVE NEWS & WEB CATALYSTS STUDY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sentColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${news.sentimentLabel} (${(news.sentimentScore * 100).toInt()}%)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.catalystSummary,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
          ),
          if (news.topHeadlines.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Latest Web Headlines:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 6),
            ...news.topHeadlines.take(3).map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.publisher,
                          style: const TextStyle(fontSize: 10, color: AppTheme.accentBlue),
                        ),
                        Text(
                          item.publishedAt,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildDualModelAssurance(BuildContext context) {
    final val = prediction.validationModel;
    final agrees = val?.agreesWithPrimary ?? true;
    final consensusScore = prediction.consensusScore;

    final consensusColor = consensusScore >= 80.0
        ? AppTheme.bullish
        : (consensusScore >= 60.0 ? AppTheme.neutral : AppTheme.bearish);

    final primColor = (prediction.signal == 'BUY' || prediction.signal == 'ACCUMULATE')
        ? AppTheme.bullish
        : ((prediction.signal == 'SELL' || prediction.signal == 'AVOID') ? AppTheme.bearish : AppTheme.neutral);

    final secSignal = val?.signal ?? prediction.signal;
    final secColor = (secSignal == 'BUY' || secSignal == 'ACCUMULATE')
        ? AppTheme.bullish
        : ((secSignal == 'SELL' || secSignal == 'AVOID') ? AppTheme.bearish : AppTheme.neutral);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: consensusColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with Consensus badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    agrees ? Icons.verified : Icons.warning_amber_rounded,
                    size: 16,
                    color: consensusColor,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'DUAL-MODEL ASSURANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: consensusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: consensusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${consensusScore.toStringAsFixed(1)}% Consensus',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: consensusColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Side-by-side model outputs
          Row(
            children: [
              // Primary Model Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Primary Model',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        prediction.modelVersion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: primColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              prediction.signal,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primColor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(prediction.confidence * 100).toInt()}% conf',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Secondary Benchmark Model Box
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secondary Validation Model',
                        style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        val?.modelName ?? 'Bayesian Consensus Quant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: secColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              secSignal,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: secColor),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${((val?.confidence ?? 0.8) * 100).toInt()}% conf',
                            style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (val?.validationNote.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(
              val!.validationNote,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
