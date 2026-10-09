import 'package:flutter/material.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/models/candle.dart';

class StockChart extends StatefulWidget {
  final List<Candle> candles;
  final String activeTimeframe;
  final ValueChanged<String> onTimeframeChanged;

  const StockChart({
    super.key,
    required this.candles,
    required this.activeTimeframe,
    required this.onTimeframeChanged,
  });

  @override
  State<StockChart> createState() => _StockChartState();
}

class _StockChartState extends State<StockChart> with SingleTickerProviderStateMixin {
  int? _hoveredIndex;
  bool _showCandles = true;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candles = widget.candles;
    final hoveredCandle = (_hoveredIndex != null && _hoveredIndex! < candles.length)
        ? candles[_hoveredIndex!]
        : (candles.isNotEmpty ? candles.last : null);

    final lastCandle = candles.isNotEmpty ? candles.last : null;
    final isLastBull = (lastCandle != null) ? (lastCandle.close >= lastCandle.open) : true;
    final liveColor = isLastBull ? AppTheme.bullish : AppTheme.bearish;

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
          // Header Controls: Timeframe tabs, Live Pulsing Badge & chart type toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Timeframes
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Pulsing Live Indicator
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final alpha = (0.4 + (_pulseController.value * 0.6)).clamp(0.0, 1.0);
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: liveColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: liveColor.withValues(alpha: alpha * 0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: liveColor.withValues(alpha: alpha),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: liveColor.withValues(alpha: alpha * 0.8),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: liveColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      ...['1D', '5D', '1M', '6M', '1Y'].map((tf) {
                        final isSelected = widget.activeTimeframe == tf;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => widget.onTimeframeChanged(tf),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accentBlue.withValues(alpha: 0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppTheme.accentBlue : Colors.transparent,
                                ),
                              ),
                              child: Text(
                                tf,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Chart mode toggle
              IconButton(
                icon: Icon(
                  _showCandles ? Icons.candlestick_chart : Icons.show_chart,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                tooltip: _showCandles ? 'Switch to Line Chart' : 'Switch to Candlestick',
                onPressed: () => setState(() => _showCandles = !_showCandles),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Price & Date Hover Inspector
          if (hoveredCandle != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Formatters.formatCurrency(hoveredCandle.close),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      hoveredCandle.timestamp,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'O: ${hoveredCandle.open.toStringAsFixed(1)}  H: ${hoveredCandle.high.toStringAsFixed(1)}  L: ${hoveredCandle.low.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Custom Candlestick Canvas with Animated Live Bar
          SizedBox(
            height: 220,
            width: double.infinity,
            child: candles.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.bullish),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanUpdate: (details) {
                          _handleHover(details.localPosition.dx, constraints.maxWidth, candles.length);
                        },
                        onTapDown: (details) {
                          _handleHover(details.localPosition.dx, constraints.maxWidth, candles.length);
                        },
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: _CandleChartPainter(
                                candles: candles,
                                hoveredIndex: _hoveredIndex,
                                showCandles: _showCandles,
                                pulseValue: _pulseController.value,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _handleHover(double dx, double width, int count) {
    if (count <= 0 || width <= 0) return;
    final index = ((dx / width) * count).floor().clamp(0, count - 1);
    setState(() {
      _hoveredIndex = index;
    });
  }
}

class _CandleChartPainter extends CustomPainter {
  final List<Candle> candles;
  final int? hoveredIndex;
  final bool showCandles;
  final double pulseValue;

  _CandleChartPainter({
    required this.candles,
    required this.hoveredIndex,
    required this.showCandles,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (candles.isEmpty) return;

    double minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    double maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);

    if ((maxPrice - minPrice).abs() < 0.01) {
      maxPrice += 1.0;
      minPrice -= 1.0;
    }

    final priceRange = maxPrice - minPrice;
    final paddingBottom = 20.0;
    final chartHeight = size.height - paddingBottom;
    final candleWidth = (size.width / candles.length).clamp(2.0, 16.0);

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = AppTheme.cardBorder.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const gridSteps = 4;
    for (int i = 0; i <= gridSteps; i++) {
      final y = chartHeight * (i / gridSteps);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);

      final priceLabel = maxPrice - (priceRange * (i / gridSteps));
      final textPainter = TextPainter(
        text: TextSpan(
          text: priceLabel.toStringAsFixed(0),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 2, y - 10));
    }

    // Latest live candle details for real-time line
    final lastCandle = candles.last;
    final lastCloseY = chartHeight - ((lastCandle.close - minPrice) / priceRange * chartHeight);
    final lastIsBull = lastCandle.close >= lastCandle.open;
    final liveColor = lastIsBull ? AppTheme.bullish : AppTheme.bearish;

    if (showCandles) {
      // Draw Candlesticks
      for (int i = 0; i < candles.length; i++) {
        final c = candles[i];
        final isLast = (i == candles.length - 1);
        final x = (i + 0.5) * (size.width / candles.length);

        final highY = chartHeight - ((c.high - minPrice) / priceRange * chartHeight);
        final lowY = chartHeight - ((c.low - minPrice) / priceRange * chartHeight);
        final openY = chartHeight - ((c.open - minPrice) / priceRange * chartHeight);
        final closeY = chartHeight - ((c.close - minPrice) / priceRange * chartHeight);

        final isBull = c.close >= c.open;
        final color = isBull ? AppTheme.bullish : AppTheme.bearish;

        // Wick
        final wickPaint = Paint()
          ..color = color
          ..strokeWidth = 1.2;
        canvas.drawLine(Offset(x, highY), Offset(x, lowY), wickPaint);

        // Body
        final bodyTop = isBull ? closeY : openY;
        final bodyBottom = isBull ? openY : closeY;
        final bodyHeight = (bodyBottom - bodyTop).abs().clamp(1.5, double.infinity);

        final bodyPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, bodyTop + (bodyHeight / 2)),
            width: candleWidth * 0.75,
            height: bodyHeight,
          ),
          bodyPaint,
        );

        // Forming candle pulse halo if this is the last bar
        if (isLast) {
          final glowRadius = 4.0 + (pulseValue * 5.0);
          final haloPaint = Paint()
            ..color = color.withValues(alpha: 0.3 * (1.0 - pulseValue))
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, closeY), glowRadius, haloPaint);

          final dotPaint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(Offset(x, closeY), 2.5, dotPaint);
        }
      }
    } else {
      // Draw smooth line
      final path = Path();
      for (int i = 0; i < candles.length; i++) {
        final c = candles[i];
        final x = (i + 0.5) * (size.width / candles.length);
        final y = chartHeight - ((c.close - minPrice) / priceRange * chartHeight);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final linePaint = Paint()
        ..color = AppTheme.accentBlue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, linePaint);
    }

    // Draw Live Dashed Price Line across the chart
    final dashPaint = Paint()
      ..color = liveColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.0;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, lastCloseY), Offset(startX + dashWidth, lastCloseY), dashPaint);
      startX += dashWidth + dashSpace;
    }

    // Live Price Pill on right axis
    final livePriceStr = lastCandle.close.toStringAsFixed(1);
    final tagPainter = TextPainter(
      text: TextSpan(
        text: livePriceStr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tagBg = Paint()..color = liveColor;
    final tagRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - tagPainter.width - 10,
        lastCloseY - 8,
        tagPainter.width + 10,
        16,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(tagRect, tagBg);
    tagPainter.paint(canvas, Offset(size.width - tagPainter.width - 5, lastCloseY - 6));

    // Draw Crosshair on hovered candle
    if (hoveredIndex != null && hoveredIndex! < candles.length) {
      final hx = (hoveredIndex! + 0.5) * (size.width / candles.length);
      final hc = candles[hoveredIndex!];
      final hy = chartHeight - ((hc.close - minPrice) / priceRange * chartHeight);

      final crosshairPaint = Paint()
        ..color = AppTheme.accentBlue.withValues(alpha: 0.8)
        ..strokeWidth = 1.0;

      canvas.drawLine(Offset(hx, 0), Offset(hx, chartHeight), crosshairPaint);
      canvas.drawCircle(Offset(hx, hy), 4.0, Paint()..color = AppTheme.accentBlue);
    }
  }

  @override
  bool shouldRepaint(covariant _CandleChartPainter oldDelegate) {
    return oldDelegate.candles != candles ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.showCandles != showCandles ||
        oldDelegate.pulseValue != pulseValue;
  }
}
