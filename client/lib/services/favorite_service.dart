import 'package:shared_preferences/shared_preferences.dart';

/// Stores favourite shop IDs locally via shared_preferences.
class FavoriteService {
  static const _key = 'favorite_shop_ids';

  static FavoriteService? _instance;
  FavoriteService._();
  static FavoriteService get instance => _instance ??= FavoriteService._();

  Future<Set<int>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map(int.parse).toSet();
  }

  Future<bool> isFavorite(int shopId) async {
    final favs = await loadFavorites();
    return favs.contains(shopId);
  }

  Future<bool> toggle(int shopId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final ids = raw.map(int.parse).toSet();
    if (ids.contains(shopId)) {
      ids.remove(shopId);
    } else {
      ids.add(shopId);
    }
    await prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
    return ids.contains(shopId);
  }
}
