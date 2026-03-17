import 'dart:async';

import 'package:localboost_shared/services/enrollment_service.dart';
import 'package:localboost_merchant/services/connectivity_service.dart';
import 'package:localboost_merchant/services/offline_queue_service.dart';

/// Listens for connectivity changes and syncs queued stamp actions.
///
/// Call [start] once at app startup. Call [dispose] when the app is closed.
class OfflineSyncService {
  final EnrollmentService _enrollmentService;
  final OfflineQueueService _queueService;
  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _sub;

  OfflineSyncService({
    required EnrollmentService enrollmentService,
    required OfflineQueueService queueService,
    required ConnectivityService connectivityService,
  })  : _enrollmentService = enrollmentService,
        _queueService = queueService,
        _connectivityService = connectivityService;

  void start() {
    _sub = _connectivityService.onlineStream.listen((online) {
      if (online) _syncQueue();
    });
    // Also attempt an initial sync in case we start with connectivity.
    _connectivityService.isOnline.then((online) {
      if (online) _syncQueue();
    });
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// Drain the queue: attempt each action, remove on success.
  Future<void> _syncQueue() async {
    final queue = await _queueService.load();
    if (queue.isEmpty) return;

    for (final action in queue) {
      try {
        final result = await _enrollmentService.addStamp(
          enrollmentId: action.enrollmentId,
          idempotencyKey: action.idempotencyKey,
        );
        // On success, the action is applied (idempotency_key prevents double-stamp).
        // On duplicate-key 200, success is also true — safe to dequeue.
        if (result.success) {
          await _queueService.dequeue(action.localUuid);
        }
      } catch (_) {
        // Leave it in the queue for the next reconnect.
      }
    }
  }
}
