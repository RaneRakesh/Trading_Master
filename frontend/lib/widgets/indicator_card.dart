import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/models/indicator.dart';

class IndicatorCard extends StatelessWidget {
  final TechnicalIndicators indicators;
  final double currentPrice;

  const IndicatorCard({
    super.key,
    required this.indicators,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Technical Indicators Engine',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Grid of Indicators
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildPill('RSI (14)', indicators.rsi.toStringAsFixed(1),
                      indicators.rsi > 50 ? AppTheme.bullish : AppTheme.bearish,
                      subtext: indicators.rsi > 70 ? 'Overbought' : (indicators.rsi < 30 ? 'Oversold' : 'Neutral')),
                  _buildPill('MACD', indicators.macd.toStringAsFixed(2),
                      indicators.macd > indicators.macdSignal ? AppTheme.bullish : AppTheme.bearish,
                      subtext: 'Signal: ${indicators.macdSignal.toStringAsFixed(1)}'),
                  _buildPill('EMA 20', '₹${indicators.ema20.toStringAsFixed(1)}',
                      currentPrice >= indicators.ema20 ? AppTheme.bullish : AppTheme.bearish,
                      subtext: currentPrice >= indicators.ema20 ? 'Above EMA' : 'Below EMA'),
                  _buildPill('EMA 50', '₹${indicators.ema50.toStringAsFixed(1)}',
                      currentPrice >= indicators.ema50 ? AppTheme.bullish : AppTheme.bearish,
                      subtext: currentPrice >= indicators.ema50 ? 'Above EMA' : 'Below EMA'),
                  _buildPill('VWAP', '₹${indicators.vwap.toStringAsFixed(1)}',
                      currentPrice >= indicators.vwap ? AppTheme.bullish : AppTheme.bearish,
                      subtext: currentPrice >= indicators.vwap ? 'Bullish Bias' : 'Bearish Bias'),
                  _buildPill('ATR (14)', '₹${indicators.atr.toStringAsFixed(1)}', AppTheme.accentBlue,
                      subtext: '${((indicators.atr / currentPrice) * 100).toStringAsFixed(1)}% volatility'),
                  _buildPill('Bollinger Upper', '₹${indicators.bbUpper.toStringAsFixed(1)}', AppTheme.textSecondary),
                  _buildPill('Bollinger Lower', '₹${indicators.bbLower.toStringAsFixed(1)}', AppTheme.textSecondary),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, String value, Color color, {String? subtext}) {
    return Container(
      width: 155,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          if (subtext != null) ...[
            const SizedBox(height: 2),
            Text(subtext, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
          ],
        ],
      ),
    );
  }
}
