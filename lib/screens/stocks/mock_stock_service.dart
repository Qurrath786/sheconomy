// lib/screens/stocks/mock_stock_service.dart
import 'dart:math';

/// Lightweight mock stock generator used for development and testing.
class MockStockService {
  static Future<Map<String, dynamic>> fetchMock(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final rnd = Random(symbol.hashCode ^ DateTime.now().day);
    final base = 100 + rnd.nextDouble() * 200;
    final prices = List<double>.generate(12, (i) {
      final noise = rnd.nextDouble() * 4 - 2; // -2..+2
      final drift = (i - 6) * 0.5;
      return double.parse((base + drift + noise).toStringAsFixed(2));
    });
    final last = prices.last;
    final prev = prices[prices.length - 2];
    return {
      'symbol': symbol.toUpperCase(),
      'price': last,
      'previous': prev,
      'prices': prices,
    };
  }
}
