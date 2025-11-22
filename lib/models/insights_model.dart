// lib/models/insights_model.dart
import 'package:flutter/foundation.dart';

class InsightsModel {
  final String userId;
  final Range range;
  final Summary summary;
  final List<TimeSeriesPoint> timeseries;
  final List<CategoryBreakdown> byCategory;
  final List<Activity> recentActivity;

  InsightsModel({
    required this.userId,
    required this.range,
    required this.summary,
    required this.timeseries,
    required this.byCategory,
    required this.recentActivity,
  });

  factory InsightsModel.fromJson(Map<String, dynamic> json) {
    return InsightsModel(
      userId: json['userId'] as String? ?? '',
      range: Range.fromJson(json['range'] as Map<String, dynamic>? ?? {}),
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      timeseries: (json['timeseries'] as List<dynamic>? ?? [])
          .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      byCategory: (json['byCategory'] as List<dynamic>? ?? [])
          .map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivity: (json['recent_activity'] as List<dynamic>? ?? [])
          .map((e) => Activity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Range {
  final String from;
  final String to;
  Range({required this.from, required this.to});
  factory Range.fromJson(Map<String, dynamic> json) {
    return Range(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }
}

class Summary {
  final double totalSavings;
  final double income;
  final double expenses;
  final double netChange;
  Summary({
    required this.totalSavings,
    required this.income,
    required this.expenses,
    required this.netChange,
  });
  factory Summary.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    return Summary(
      totalSavings: _toDouble(json['total_savings']),
      income: _toDouble(json['income']),
      expenses: _toDouble(json['expenses']),
      netChange: _toDouble(json['net_change'] ?? 0),
    );
  }
}

class TimeSeriesPoint {
  final DateTime date;
  final double balance;
  final double income;
  final double expense;
  TimeSeriesPoint({
    required this.date,
    required this.balance,
    required this.income,
    required this.expense,
  });
  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    final dateStr = json['date'] as String? ?? '';
    return TimeSeriesPoint(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      balance: _toDouble(json['balance']),
      income: _toDouble(json['income']),
      expense: _toDouble(json['expenses'] ?? json['expense']),
    );
  }
}

class CategoryBreakdown {
  final String category;
  final double amount;
  CategoryBreakdown({required this.category, required this.amount});
  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    return CategoryBreakdown(
      category: (json['category'] as String?) ?? '',
      amount: _toDouble(json['amount']),
    );
  }
}

class Activity {
  final String id;
  final String title;
  final double amount;
  final String type; // "expense" or "income"
  final String category;
  final DateTime date;

  Activity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0);
    final dateStr = json['date'] as String? ?? '';
    return Activity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: _toDouble(json['amount']),
      type: json['type'] as String? ?? '',
      category: json['category'] as String? ?? '',
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
    );
  }
}
