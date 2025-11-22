import 'package:flutter/material.dart';
import '../../theme/theme.dart';

import 'widgets/sip_calculator.dart';
import 'widgets/emi_calculator.dart';
import 'widgets/budget_planner.dart';
import 'widgets/savings_goal.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'Financial Tools',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 16),

        SipCalculator(),
        EmiCalculator(),
        BudgetPlanner(),
        SavingsGoal(),
      ],
    );
  }
}
