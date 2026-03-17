import 'package:shared_preferences/shared_preferences.dart';

import 'package:localboost_merchant/models/offline_stamp_action.dart';

/// Persists and retrieves offline stamp actions using SharedPreferences.
class OfflineQueueService {
  static const _key = 'offline_stamp_queue';

  /// Load all queued actions from disk.
  Future<List<OfflineStampAction>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map(OfflineStampAction.fromJsonString).toList();
  }

  /// Append an action to the queue.
  Future<void> enqueue(OfflineStampAction action) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(action.toJsonString());
    await prefs.setStringList(_key, raw);
  }

  /// Remove an action from the queue by its localUuid.
  Future<void> dequeue(String localUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((s) {
      final a = OfflineStampAction.fromJsonString(s);
      return a.localUuid == localUuid;
    });
    await prefs.setStringList(_key, raw);
  }

  /// Clear the entire queue (e.g. after a successful full sync).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
