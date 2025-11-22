// lib/services/insights_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/insights_model.dart';

class InsightsService {
  // set this correctly depending on runtime:
  // Web: http://localhost:3000
  // Android emulator: http://10.0.2.2:3000
  final String baseUrl = "http://localhost:3000";

  Future<InsightsModel> fetchInsights(String from, String to) async {
    final url = "$baseUrl/api/insights?from=$from&to=$to";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    // debug logs — check flutter run console
    print('INSIGHTS: GET $uri');
    print('INSIGHTS: status ${response.statusCode}');
    print('INSIGHTS: body ${response.body}');

    if (response.statusCode != 200) {
      throw Exception("Failed to load insights: ${response.statusCode}");
    }

    final Map<String, dynamic> jsonMap =
        json.decode(response.body) as Map<String, dynamic>;
    return InsightsModel.fromJson(jsonMap);
  }
}
