import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/theme.dart';
import 'tool_card.dart';
import 'number_field.dart';

class BudgetPlanner extends StatefulWidget {
  const BudgetPlanner({super.key});

  @override
  State<BudgetPlanner> createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  final _income = TextEditingController();
  final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  String _result = '';

  void _calculate() {
    final income = double.tryParse(_income.text);
    if (income == null) {
      setState(() => _result = 'Enter valid income.');
      return;
    }

    final needs = income * 0.5;
    final wants = income * 0.3;
    final savings = income * 0.2;

    setState(() {
      _result =
          'Needs (50%): ${_currency.format(needs)}\n'
          'Wants (30%): ${_currency.format(wants)}\n'
          'Savings (20%): ${_currency.format(savings)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      title: 'Budget Planner (50/30/20)',
      subtitle: 'Plan your monthly budget',
      icon: Icons.pie_chart_outline,
      child: Column(
        children: [
          NumberField(controller: _income, label: 'Monthly Income (₹)'),
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
