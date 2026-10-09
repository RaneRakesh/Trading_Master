import 'package:flutter_test/flutter_test.dart';
import 'package:trading_master/main.dart';
import 'package:trading_master/models/stock.dart';
import 'package:trading_master/models/prediction.dart';
import 'package:trading_master/models/position_size.dart';

void main() {
  testWidgets('App initializes and renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const TradingMasterApp());
    expect(find.text('Trading Master AI'), findsOneWidget);
  });

  test('Stock model deserialization', () {
    final stock = Stock.fromJson({
      'symbol': 'RELIANCE',
      'company_name': 'Reliance Industries Ltd',
      'exchange': 'NSE',
      'sector': 'Energy',
      'current_price': 1420.5,
      'change': 15.2,
      'change_percent': 1.08,
      'open': 1405.0,
      'high': 1425.0,
      'low': 1400.0,
      'close': 1420.5,
      'volume': 150000,
      'timestamp': '2026-09-10 15:30:00',
    });

    expect(stock.symbol, 'RELIANCE');
    expect(stock.currentPrice, 1420.5);
    expect(stock.changePercent, 1.08);
  });

  test('Prediction model deserialization and bullish flag', () {
    final pred = Prediction.fromJson({
      'symbol': 'TCS',
      'mode': 'swing',
      'timestamp': '2026-09-10 15:30:00',
      'current_price': 4150.0,
      'signal': 'BUY',
      'direction': 'BULLISH',
      'probability': 0.72,
      'confidence': 0.72,
      'target': 4280.0,
      'stop_loss': 4080.0,
      'risk_reward_ratio': 1.85,
      'horizon': '5 trading days (Swing)',
      'risk_level': 'Medium',
      'reasons': ['Price above 20 EMA', 'Positive momentum'],
      'risk_factors': ['Moderate volatility'],
      'model_version': 'swing_v2.0',
    });

    expect(pred.signal, 'BUY');
    expect(pred.isBullish, true);
    expect(pred.reasons.length, 2);
  });

  test('PositionSizeResult calculation verification', () {
    final pos = PositionSizeResult.fromJson({
      'capital': 100000.0,
      'risk_percent': 1.0,
      'max_risk_amount': 1000.0,
      'risk_per_share': 20.0,
      'recommended_shares': 50,
      'total_position_value': 71000.0,
      'capital_allocated_percent': 71.0,
      'risk_reward_ratio': 3.5,
    });

    expect(pos.recommendedShares, 50);
    expect(pos.maxRiskAmount, 1000.0);
    expect(pos.riskRewardRatio, 3.5);
  });

  test('Stock isTrending deserialization verification', () {
    final trendingStock = Stock.fromJson({
      'symbol': 'TATAMOTORS',
      'company_name': 'Tata Motors Ltd',
      'exchange': 'NSE',
      'sector': 'Automotive',
      'current_price': 980.0,
      'change': 24.5,
      'change_percent': 2.56,
      'open': 960.0,
      'high': 985.0,
      'low': 955.0,
      'close': 980.0,
      'volume': 4500000,
      'timestamp': '2026-09-15 15:30:00',
      'is_trending': true,
    });

    expect(trendingStock.symbol, 'TATAMOTORS');
    expect(trendingStock.isTrending, true);
  });
}
