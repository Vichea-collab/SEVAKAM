import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/app_env.dart';
import '../../data/network/backend_api_client.dart';
import '../../domain/entities/home_promotion.dart';

class HomePromotionState {
  static final BackendApiClient _apiClient = BackendApiClient(
    baseUrl: AppEnv.apiBaseUrl(),
    bearerToken: AppEnv.apiAuthToken(),
  );

  static final ValueNotifier<List<HomePromotion>> promotions = ValueNotifier(
    const <HomePromotion>[],
  );
  static final ValueNotifier<bool> loading = ValueNotifier(false);

  static bool _refreshing = false;

  static void setBackendToken(String token, {bool refresh = true}) {
    _apiClient.setBearerToken(token);
    if (token.trim().isEmpty) {
      promotions.value = const <HomePromotion>[];
      return;
    }
    if (refresh) {
      unawaited(HomePromotionState.refresh());
    }
  }

  static Future<void> refresh({String city = ''}) async {
    if (_refreshing) return;
    _refreshing = true;
    loading.value = true;
    try {
      final query = <String>[
        'placement=finder_home',
        if (city.trim().isNotEmpty)
          'city=${Uri.encodeQueryComponent(city.trim())}',
      ].join('&');
      final path = query.isEmpty
          ? '/api/users/promotions'
          : '/api/users/promotions?$query';
      final response = await _apiClient.getJson(path);
      final data = response['data'];
      if (data is! List) {
        promotions.value = const <HomePromotion>[];
        return;
      }
      promotions.value = data
          .whereType<Map>()
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .map(HomePromotion.fromMap)
          .toList(growable: false);
    } catch (_) {
      // Keep last good promotions when refresh fails.
    } finally {
      loading.value = false;
      _refreshing = false;
    }
  }
}
