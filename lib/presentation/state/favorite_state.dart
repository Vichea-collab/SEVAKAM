import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteState {
  static final ValueNotifier<Set<String>> favoriteUids = ValueNotifier({});
  static const String _key = 'favorite_provider_uids';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    favoriteUids.value = list.toSet();
  }

  static bool isFavorite(String uid) => favoriteUids.value.contains(uid);

  static Future<void> toggleFavorite(String uid) async {
    final current = Set<String>.from(favoriteUids.value);
    if (current.contains(uid)) {
      current.remove(uid);
    } else {
      current.add(uid);
    }
    favoriteUids.value = current;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, current.toList());
  }
}
