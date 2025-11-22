// lib/screens/stocks/stock_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple wrapper for live providers (Finnhub example).
/// Returns a Map with keys: symbol, price, previous, prices (List<double>)
class StockApiService {
  static Future<Map<String, dynamic>> fetchFinnhub(
    String symbol,
    String apiKey,
  ) async {
    final quoteUri = Uri.https('finnhub.io', '/api/v1/quote', {
      'symbol': symbol,
      'token': apiKey,
    });
    final quoteResp = await http.get(quoteUri);
    if (quoteResp.statusCode != 200) {
      throw Exception('HTTP ${quoteResp.statusCode}');
    }
    final quoteJson = json.decode(quoteResp.body) as Map<String, dynamic>;
    final current = (quoteJson['c'] ?? 0).toDouble();
    final previous = (quoteJson['pc'] ?? current).toDouble();

    // candles for recent history (fallback to [previous, current] if unavailable)
    final now = DateTime.now();
    final from =
        (now.subtract(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000)
            .toString();
    final to = (now.millisecondsSinceEpoch ~/ 1000).toString();
    final candlesUri = Uri.https('finnhub.io', '/api/v1/stock/candle', {
      'symbol': symbol,
      'resolution': '60',
      'from': from,
      'to': to,
      'token': apiKey,
    });

    final candlesResp = await http.get(candlesUri);
    List<double> prices;
    if (candlesResp.statusCode == 200) {
      final cand = json.decode(candlesResp.body) as Map<String, dynamic>;
      if (cand['s'] == 'ok' && cand['c'] != null) {
        prices = (cand['c'] as List).map((e) => (e as num).toDouble()).toList();
      } else {
        prices = [previous, current];
      }
    } else {
      prices = [previous, current];
    }

    return {
      'symbol': symbol.toUpperCase(),
      'price': current,
      'previous': previous,
      'prices': prices,
    };
  }

  // Add other provider wrappers (AlphaVantage etc.) here similarly.
}
