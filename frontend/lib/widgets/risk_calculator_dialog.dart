import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trading_master/core/theme/app_theme.dart';
import 'package:trading_master/core/utils/formatters.dart';
import 'package:trading_master/providers/position_calculator_provider.dart';

class RiskCalculatorDialog extends StatefulWidget {
  final double currentPrice;
  final double defaultStopLoss;
  final double defaultTarget;

  const RiskCalculatorDialog({
    super.key,
    required this.currentPrice,
    required this.defaultStopLoss,
    required this.defaultTarget,
  });

  @override
  State<RiskCalculatorDialog> createState() => _RiskCalculatorDialogState();
}

class _RiskCalculatorDialogState extends State<RiskCalculatorDialog> {
  late TextEditingController _capitalController;
  late TextEditingController _riskPctController;
  late TextEditingController _entryController;
  late TextEditingController _stopController;
  late TextEditingController _targetController;

  @override
  void initState() {
    super.initState();
    _capitalController = TextEditingController(text: '100000');
    _riskPctController = TextEditingController(text: '1.0');
    _entryController = TextEditingController(text: widget.currentPrice.toStringAsFixed(1));
    _stopController = TextEditingController(text: widget.defaultStopLoss.toStringAsFixed(1));
    _targetController = TextEditingController(text: widget.defaultTarget.toStringAsFixed(1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PositionCalculatorProvider>().updateParameters(
        capital: 100000,
        riskPercent: 1.0,
        entryPrice: widget.currentPrice,
        stopLoss: widget.defaultStopLoss,
        targetPrice: widget.defaultTarget,
      );
    });
  }

  @override
  void dispose() {
    _capitalController.dispose();
    _riskPctController.dispose();
    _entryController.dispose();
    _stopController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final cap = double.tryParse(_capitalController.text) ?? 100000;
    final risk = double.tryParse(_riskPctController.text) ?? 1.0;
    final entry = double.tryParse(_entryController.text) ?? widget.currentPrice;
    final stop = double.tryParse(_stopController.text) ?? widget.defaultStopLoss;
    final target = double.tryParse(_targetController.text) ?? widget.defaultTarget;

    context.read<PositionCalculatorProvider>().updateParameters(
      capital: cap,
      riskPercent: risk,
      entryPrice: entry,
      stopLoss: stop,
      targetPrice: target,
    );
  }

  @override
  Widget build(BuildContext context) {
    final calc = context.watch<PositionCalculatorProvider>();
    final result = calc.result;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Risk & Position Sizing Calculator',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.shield_outlined, size: 16, color: AppTheme.bullish),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Capital Protection Rule: Calculates the exact number of shares to buy so you never lose more than your chosen Risk % (e.g. 1%) if the stop loss is triggered.',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            // Form Inputs
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Trading Capital (₹)', _capitalController),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField('Risk % per Trade', _riskPctController),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Entry Price (₹)', _entryController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Stop Loss (₹)', _stopController)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Target (₹)', _targetController)),
              ],
            ),

            const SizedBox(height: 20),

            // Computed Results Card
            if (result != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recommended Shares', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          '${result.recommendedShares} Shares',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.bullish),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Capital at Risk', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          Formatters.formatCurrency(result.maxRiskAmount),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.bearish),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Position Value', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        Text(
                          Formatters.formatCurrency(result.totalPositionValue),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    if (result.potentialProfit != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Potential Reward', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Text(
                            Formatters.formatCurrency(result.potentialProfit!),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.bullish),
                          ),
                        ],
                      ),
                    ],
                    if (result.riskRewardRatio != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Risk : Reward Ratio', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          Text(
                            '1 : ${result.riskRewardRatio!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentBlue),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => _onFieldChanged(),
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
