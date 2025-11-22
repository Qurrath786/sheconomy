import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/theme.dart';
import 'tool_card.dart';
import 'number_field.dart';

class SavingsGoal extends StatefulWidget {
  const SavingsGoal({super.key});

  @override
  State<SavingsGoal> createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  final _target = TextEditingController();
  final _saved = TextEditingController();

  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  String _result = '';

  void _calculate() {
    final t = double.tryParse(_target.text);
    final s = double.tryParse(_saved.text);

    if (t == null || s == null) {
      setState(() => _result = 'Enter valid values.');
      return;
    }

    final remaining = (t - s).clamp(0, double.infinity);
    final percent = (s / t * 100).clamp(0, 100);

    setState(() {
      _result =
          'Progress: ${percent.toStringAsFixed(1)}%\n'
          'Remaining: ${_currency.format(remaining)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      title: 'Savings Goal Tracker',
      subtitle: 'Track saving progress',
      icon: Icons.flag_outlined,
      child: Column(
        children: [
          NumberField(controller: _target, label: 'Goal Amount (₹)'),
          const SizedBox(height: 8),
          NumberField(controller: _saved, label: 'Already Saved (₹)'),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('Update'),
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
