import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/providers/market_provider.dart';
import 'package:trading_master/providers/prediction_provider.dart';
import 'package:trading_master/providers/position_calculator_provider.dart';
import 'package:trading_master/screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradingMasterApp());
}

class TradingMasterApp extends StatelessWidget {
  const TradingMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => PositionCalculatorProvider()),
      ],
      child: MaterialApp(
        title: 'Trading Master AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
