import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/theme.dart';
import 'tool_card.dart';
import 'number_field.dart';

class SipCalculator extends StatefulWidget {
  const SipCalculator({super.key});

  @override
  State<SipCalculator> createState() => _SipCalculatorState();
}

class _SipCalculatorState extends State<SipCalculator> {
  final _amount = TextEditingController();
  final _years = TextEditingController();
  final _rate = TextEditingController(text: '12');

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  String _result = '';

  void _calculate() {
    final p = double.tryParse(_amount.text);
    final y = double.tryParse(_years.text);
    final r = double.tryParse(_rate.text);

    if (p == null || y == null || r == null) {
      setState(() => _result = 'Please enter valid values.');
      return;
    }

    final months = (y * 12).toInt();
    final monthlyRate = r / 12 / 100;

    final fv =
        p *
        (((pow(1 + monthlyRate, months) - 1) / monthlyRate) *
            (1 + monthlyRate));
    final invested = p * months;
    final gain = fv - invested;

    setState(() {
      _result =
          'Invested: ${_currency.format(invested)}\n'
          'Future Value: ${_currency.format(fv)}\n'
          'Gain: ${_currency.format(gain)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      title: 'SIP Calculator',
      subtitle: 'Plan monthly investments',
      icon: Icons.savings_outlined,
      child: Column(
        children: [
          NumberField(controller: _amount, label: 'Monthly Investment (₹)'),
          const SizedBox(height: 8),
          NumberField(controller: _years, label: 'Years'),
          const SizedBox(height: 8),
          NumberField(controller: _rate, label: 'Return (% per year)'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _result,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
