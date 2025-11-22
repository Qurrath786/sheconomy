import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/theme.dart';
import 'tool_card.dart';
import 'number_field.dart';

class EmiCalculator extends StatefulWidget {
  const EmiCalculator({super.key});

  @override
  State<EmiCalculator> createState() => _EmiCalculatorState();
}

class _EmiCalculatorState extends State<EmiCalculator> {
  final _amount = TextEditingController();
  final _years = TextEditingController();
  final _rate = TextEditingController();

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

    final powVal = pow(1 + monthlyRate, months);
    final emi = p * monthlyRate * powVal / (powVal - 1);

    final totalPay = emi * months;
    final interest = totalPay - p;

    setState(() {
      _result =
          'Monthly EMI: ${_currency.format(emi)}\n'
          'Total Interest: ${_currency.format(interest)}\n'
          'Total Payment: ${_currency.format(totalPay)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      title: 'Loan EMI Calculator',
      subtitle: 'Calculate EMI & interest',
      icon: Icons.request_quote_outlined,
      child: Column(
        children: [
          NumberField(controller: _amount, label: 'Loan Amount (₹)'),
          const SizedBox(height: 8),
          NumberField(controller: _years, label: 'Tenure (years)'),
          const SizedBox(height: 8),
          NumberField(controller: _rate, label: 'Interest Rate (%)'),
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
