import 'package:flutter/foundation.dart';

class FavoriteState {
  static final ValueNotifier<Set<String>> favoriteUids = ValueNotifier({});

  static bool isFavorite(String uid) => favoriteUids.value.contains(uid);

  static void toggleFavorite(String uid) {
    final current = Set<String>.from(favoriteUids.value);
    if (current.contains(uid)) {
      current.remove(uid);
    } else {
      current.add(uid);
    }
    favoriteUids.value = current;
  }
}
