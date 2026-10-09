import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/models/prediction.dart';

class InvestmentScoreCard extends StatelessWidget {
  final InvestmentScorecard score;

  const InvestmentScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final overall = score.overall;
    final rating = overall >= 80
        ? 'STRONG BUY'
        : (overall >= 65 ? 'POSITIVE' : (overall >= 50 ? 'NEUTRAL' : 'WEAK'));
    final ratingColor = overall >= 65 ? AppTheme.bullish : (overall >= 50 ? AppTheme.neutral : AppTheme.bearish);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Investment Fundamental Scorecard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ratingColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  rating,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: ratingColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Big Overall Score Bar
          Row(
            children: [
              Text(
                '${score.overall.toInt()}',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: ratingColor),
              ),
              const Text('/100', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (score.overall / 100.0).clamp(0.0, 1.0),
                    backgroundColor: AppTheme.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: AppTheme.cardBorder),
          const SizedBox(height: 12),

          // Subscore Breakdown
          _buildScoreRow('Financial Health & Quality', score.fundamentals),
          const SizedBox(height: 10),
          _buildScoreRow('Growth & Margins', score.growth),
          const SizedBox(height: 10),
          _buildScoreRow('Valuation Multiple', score.valuation),
          const SizedBox(height: 10),
          _buildScoreRow('Long-Term Technical Trend', score.technicalTrend),
          const SizedBox(height: 10),
          _buildScoreRow('Balance Sheet & Risk Safety', score.riskScore),

          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardBorder),
          const SizedBox(height: 12),

          // Key Ratios
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatio('P/E Ratio', score.peRatio?.toStringAsFixed(1) ?? 'N/A'),
              _buildRatio('P/B Ratio', score.pbRatio?.toStringAsFixed(1) ?? 'N/A'),
              _buildRatio('ROE %', '${score.roe?.toStringAsFixed(1) ?? 'N/A'}%'),
              _buildRatio('Debt/Equity', score.debtToEquity?.toStringAsFixed(2) ?? 'N/A'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double value) {
    final color = value >= 70 ? AppTheme.bullish : (value >= 50 ? AppTheme.neutral : AppTheme.bearish);
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100.0).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 42,
          child: Text(
            '${value.toInt()}/100',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildRatio(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
