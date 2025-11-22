import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Text(
          'Please log in to see insights.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading insights\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        double monthlyIncome = 0;
        double monthlyExpense = 0;
        final Map<String, double> categoryTotals = {};

        // Aggregate data
        for (final doc in docs) {
          final data = doc.data();
          final amount = (data['amount'] ?? 0).toDouble();
          final type = (data['type'] ?? '') as String;
          final category = (data['category'] ?? 'Other') as String;
          final ts = data['date'] as Timestamp?;
          final date = ts?.toDate();

          if (date == null) continue;

          final now = DateTime.now();
          // Only consider current month for these insights
          if (date.year == now.year && date.month == now.month) {
            if (type == 'income') {
              monthlyIncome += amount;
            } else if (type == 'expense') {
              monthlyExpense += amount;
              categoryTotals[category] =
                  (categoryTotals[category] ?? 0) + amount;
            }
          }
        }

        final netBalance = monthlyIncome - monthlyExpense;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== Income vs Expense Bar Chart =====
            const Text(
              'Monthly Income vs Expenses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Quick overview of this month\'s cash flow',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          if (value.toInt() == 0) text = 'Income';
                          if (value.toInt() == 1) text = 'Expenses';
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyIncome,
                          width: 24,
                          color: AppTheme.successColor,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyExpense,
                          width: 24,
                          color: AppTheme.errorColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== Category Pie Chart =====
            const Text(
              'Expenses by Category (This Month)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'See where most of your money is going',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),

            if (categoryTotals.isEmpty)
              const Text(
                'No expenses recorded for this month yet.',
                style: TextStyle(color: AppTheme.textSecondary),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        sections: _buildPieSections(categoryTotals),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: categoryTotals.entries
                        .map(
                          (e) => Chip(
                            label: Text(
                              '${e.key}: ₹${e.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: AppTheme.primaryColor.withValues(
                              alpha: 0.06,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // ===== Net Balance Text =====
            Text(
              'Net balance this month: ₹${netBalance.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: netBalance >= 0
                    ? AppTheme.successColor
                    : AppTheme.errorColor,
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(
    Map<String, double> categoryTotals,
  ) {
    final total = categoryTotals.values.fold<double>(0, (prev, v) => prev + v);
    if (total == 0) return [];

    final colors = <Color>[
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
    ];

    var i = 0;
    return categoryTotals.entries.map((entry) {
      final value = entry.value;
      final percent = (value / total) * 100;
      final color = colors[i % colors.length];
      i++;

      return PieChartSectionData(
        value: value,
        color: color,
        title: '${percent.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
