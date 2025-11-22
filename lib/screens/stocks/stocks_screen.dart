// lib/screens/stocks/stocks_screen.dart
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../theme/theme.dart';
import 'mock_stock_service.dart';
import 'stock_api_service.dart';
import 'risk_engine.dart';

/// StocksScreen
/// - Mock mode (default) for quick testing
/// - Live mode (Finnhub / AlphaVantage) when FINNHUB_KEY / ALPHA_VANTAGE_KEY set in .env
/// - In-memory cache to avoid hitting API limits
/// - Save watchlist to Firestore under users/{uid}/watchlist/{SYMBOL}
class StocksScreen extends StatefulWidget {
  const StocksScreen({super.key});

  @override
  State<StocksScreen> createState() => _StocksScreenState();
}

class _StocksScreenState extends State<StocksScreen> {
  final _symbolController = TextEditingController(text: 'AAPL');
  bool _loading = false;
  bool _useMock = true;
  String? _error;

  // displayed data
  String? _symbol;
  double? _price;
  double? _change;
  double? _changePercent;
  DateTime? _timestamp;
  List<double> _recentPrices = [];

  final _currency = NumberFormat.simpleCurrency(name: 'USD');

  // simple in-memory cache: symbol -> entry
  final Map<String, Map<String, dynamic>> _cache = {};

  @override
  void dispose() {
    _symbolController.dispose();
    super.dispose();
  }

  // ---------- MOCK ----------

  Future<void> _fetchMock(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 350));
    final rnd = Random(symbol.hashCode ^ DateTime.now().day);
    final base = 100 + rnd.nextDouble() * 200;
    final prices = List<double>.generate(12, (i) {
      final noise = rnd.nextDouble() * 4 - 2;
      final drift = (i - 6) * 0.5;
      return double.parse((base + drift + noise).toStringAsFixed(2));
    });

    final last = prices.last;
    final prev = prices[prices.length - 2];

    _saveToCache(
      symbol,
      last,
      last - prev,
      prev != 0 ? ((last - prev) / prev) * 100 : 0,
      prices,
    );

    setState(() {
      _symbol = symbol.toUpperCase();
      _price = last;
      _change = last - prev;
      _changePercent = prev != 0 ? (_change! / prev) * 100 : 0;
      _timestamp = DateTime.now();
      _recentPrices = prices;
      _error = null;
    });
  }

  // ---------- FINNHUB LIVE ----------

  Future<void> _fetchFinnhubLive(String symbol, String apiKey) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
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
          final List<dynamic> cs = cand['c'];
          prices = cs.map((e) => (e as num).toDouble()).toList();
        } else {
          prices = [previous, current];
        }
      } else {
        prices = [previous, current];
      }

      _saveToCache(
        symbol,
        current,
        current - previous,
        previous != 0 ? ((current - previous) / previous) * 100 : 0,
        prices,
      );

      setState(() {
        _symbol = symbol.toUpperCase();
        _price = current;
        _change = current - previous;
        _changePercent = previous != 0 ? (_change! / previous) * 100 : 0;
        _timestamp = DateTime.now();
        _recentPrices = prices;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ---------- ALPHA VANTAGE (optional) ----------

  Future<void> _fetchAlphaVantage(String symbol, String apiKey) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.https('www.alphavantage.co', '/query', {
        'function': 'TIME_SERIES_INTRADAY',
        'symbol': symbol,
        'interval': '60min',
        'outputsize': 'compact',
        'apikey': apiKey,
      });

      final resp = await http.get(uri);
      if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
      final Map<String, dynamic> jsonResp =
          json.decode(resp.body) as Map<String, dynamic>;

      if (jsonResp.containsKey('Note') ||
          jsonResp.containsKey('Error Message')) {
        throw Exception(
          jsonResp['Note'] ?? jsonResp['Error Message'] ?? 'AlphaVantage error',
        );
      }

      final tsKey = jsonResp.keys.firstWhere(
        (k) => k.toLowerCase().contains('time series'),
        orElse: () => '',
      );
      if (tsKey.isEmpty) {
        throw Exception('Unexpected response format from AlphaVantage');
      }

      final Map<String, dynamic> series = Map<String, dynamic>.from(
        jsonResp[tsKey],
      );
      final entries = series.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      final prices = entries.map((e) {
        final closeStr = (e.value as Map)['4. close'].toString();
        return double.tryParse(closeStr) ?? 0.0;
      }).toList();

      if (prices.isEmpty) throw Exception('No price points');

      final last = prices.first;
      final prev = prices.length > 1 ? prices[1] : last;

      _saveToCache(
        symbol,
        last,
        last - prev,
        prev != 0 ? ((last - prev) / prev) * 100 : 0,
        prices.reversed.toList(),
      );

      setState(() {
        _symbol = symbol.toUpperCase();
        _price = last;
        _change = last - prev;
        _changePercent = prev != 0 ? (_change! / prev) * 100 : 0;
        _timestamp = DateTime.now();
        _recentPrices = prices.reversed.toList();
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ---------- PUBLIC FETCH (cache-aware) ----------

  Future<void> _fetchStock() async {
    final symbol = _symbolController.text.trim().toUpperCase();
    if (symbol.isEmpty) {
      setState(() => _error = 'Enter a symbol to search');
      return;
    }

    // check cache (valid for 60s)
    final now = DateTime.now();
    if (_cache.containsKey(symbol)) {
      final entry = _cache[symbol]!;
      final ts = entry['ts'] as DateTime;
      if (now.difference(ts) < const Duration(seconds: 60)) {
        setState(() {
          _symbol = entry['symbol'] as String;
          _price = (entry['price'] as num).toDouble();
          _change = (entry['change'] as num).toDouble();
          _changePercent = (entry['changePercent'] as num).toDouble();
          _timestamp = entry['ts'] as DateTime;
          _recentPrices = List<double>.from(entry['prices'] as List<dynamic>);
          _error = null;
        });
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_useMock) {
        await _fetchMock(symbol);
      } else {
        final finnhubKey = dotenv.env['FINNHUB_KEY'];
        if (finnhubKey != null && finnhubKey.isNotEmpty) {
          await _fetchFinnhubLive(symbol, finnhubKey);
        } else {
          final alphaKey = dotenv.env['ALPHA_VANTAGE_KEY'];
          if (alphaKey != null && alphaKey.isNotEmpty) {
            await _fetchAlphaVantage(symbol, alphaKey);
          } else {
            await _fetchMock(symbol);
            setState(() {
              _error =
                  'No FINNHUB_KEY or ALPHA_VANTAGE_KEY found in .env — showing mock data';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ---------- Cache helper ----------

  void _saveToCache(
    String symbol,
    double price,
    double change,
    double changePercent,
    List<double> prices,
  ) {
    _cache[symbol] = {
      'symbol': symbol.toUpperCase(),
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'ts': DateTime.now(),
      'prices': prices,
    };
  }

  // ---------- Watchlist (Firestore) ----------

  Future<void> _addToWatchlist(String symbol) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to save to watchlist')),
      );
      return;
    }
    final uid = user.uid;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('watchlist')
          .doc(symbol.toUpperCase())
          .set({
            'symbol': symbol.toUpperCase(),
            'addedAt': FieldValue.serverTimestamp(),
            'lastPrice': _price ?? 0,
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to watchlist')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    }
  }

  // ---------- Risk helpers (local) ----------

  int _computeRiskScore(List<double> prices, double? changePercent) =>
      computeRiskScore(prices, changePercent);

  String _riskExplanation(int score) {
    if (score < 25) {
      return 'Low volatility — typically safer for conservative investors.';
    }
    if (score < 55) {
      return 'Moderate volatility — suitable for balanced portfolios.';
    }
    if (score < 80) {
      return 'High volatility — suitable for experienced investors.';
    }
    return 'Very high volatility — risky, consider carefully and diversify.';
  }

  String _suggestion(int score, double? changePercent) {
    if (score < 30 && (changePercent ?? 0) > -2) return 'Buy (low risk)';
    if (score < 60 && (changePercent ?? 0) > -5) return 'Hold';
    if ((changePercent ?? 0) < -5 || score > 70) {
      return 'Consider Sell or Research';
    }
    return 'Watch / Hold';
  }

  Color _changeColor(double? change) {
    if (change == null) return Colors.grey;
    return change >= 0 ? AppTheme.successColor : AppTheme.errorColor;
  }

  Widget _buildSparkline() {
    if (_recentPrices.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No chart data')),
      );
    }
    final spots = <FlSpot>[];
    for (var i = 0; i < _recentPrices.length; i++) {
      spots.add(FlSpot(i.toDouble(), _recentPrices[i]));
    }
    final minY = _recentPrices.reduce(min);
    final maxY = _recentPrices.reduce(max);

    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          minY: minY * 0.995,
          maxY: maxY * 1.005,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primaryColor,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primaryColor.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final risk = _recentPrices.isNotEmpty
        ? _computeRiskScore(_recentPrices, _changePercent)
        : 0;
    final suggestion = _suggestion(risk, _changePercent);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Stocks',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _symbolController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Symbol (eg: AAPL, TCS.NS)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _loading ? null : () async => await _fetchStock(),
              child: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Switch(
              value: _useMock,
              onChanged: (v) => setState(() => _useMock = v),
            ),
            const Text('Use Mock Data (toggle off for live API)'),
            const Spacer(),
            if (!_useMock)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Live API settings'),
                      content: const Text(
                        'To use live mode: add FINNHUB_KEY (or ALPHA_VANTAGE_KEY) to your .env file in project root.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_error != null)
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        if (_symbol != null) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _symbol!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _price != null ? _price!.toStringAsFixed(2) : '-',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_change != null)
                        Text(
                          '${_change! >= 0 ? '+' : ''}${_change!.toStringAsFixed(2)} (${_changePercent != null ? '${_changePercent!.toStringAsFixed(2)}%' : '-'})',
                          style: TextStyle(color: _changeColor(_change)),
                        ),
                      const Spacer(),
                      if (_timestamp != null)
                        Text(
                          DateFormat('dd MMM HH:mm').format(_timestamp!),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSparkline(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _addToWatchlist(_symbol!),
                        child: const Text('Add to Watchlist'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Score',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: risk / 100,
                          color: _riskColor(risk),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$risk/100'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_riskExplanation(risk)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Suggestion: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(suggestion),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Card(
          color: Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'How Stocks feature works',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text('- Toggle Mock Data to experiment without API keys.'),
                Text(
                  '- For live prices, turn off Mock and add FINNHUB_KEY to your .env file.',
                ),
                Text(
                  '- Risk score is a simple heuristic (volatility + recent move). Educational only.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _riskColor(int risk) {
    if (risk < 25) return Colors.green;
    if (risk < 55) return Colors.orange;
    return Colors.red;
  }
}
