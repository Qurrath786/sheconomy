// lib/screens/stocks/risk_engine.dart
import 'dart:math';

/// Compute a simple risk score (0..100) from a series of prices and recent change.
/// Volatility (std dev of returns) dominates the score; changePercent adds small weight.
int computeRiskScore(List<double> prices, double? changePercent) {
  if (prices.length < 2) return 20;
  final returns = <double>[];
  for (var i = 1; i < prices.length; i++) {
    final prev = prices[i - 1];
    final cur = prices[i];
    if (prev == 0) continue;
    returns.add((cur - prev) / prev);
  }
  if (returns.isEmpty) return 20;
  final mean = returns.reduce((a, b) => a + b) / returns.length;
  final variance =
      returns.map((r) => pow(r - mean, 2)).reduce((a, b) => a + b) /
      returns.length;
  final stddev = sqrt(variance);
  final volScore = (stddev * 100).clamp(0, 100) * 0.8;
  final changeScore = ((changePercent ?? 0).abs()).clamp(0, 100) * 0.2;
  final base = volScore + changeScore;
  return base.clamp(0, 100).round();
}
