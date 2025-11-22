// lib/providers/insights_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/insights_service.dart';
import '../models/insights_model.dart';

final insightsServiceProvider = Provider<InsightsService>(
  (ref) => InsightsService(),
);

final insightsProvider =
    FutureProvider.family<InsightsModel, Map<String, String>>((
      ref,
      params,
    ) async {
      final service = ref.read(insightsServiceProvider);
      final from = params['from'] ?? '';
      final to = params['to'] ?? '';
      return service.fetchInsights(from, to);
    });
