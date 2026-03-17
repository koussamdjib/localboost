part of '../notification_service.dart';

extension NotificationServiceMessagesX on NotificationService {
  /// Show stamp collection notification
  Future<void> showStampCollectedNotification({
    required String shopName,
    required int stampsCollected,
    required int stampsRequired,
  }) async {
    if (!_shouldShowNotification(NotificationType.stampCollected)) return;

    final remaining = stampsRequired - stampsCollected;
    const title = '✓ Timbre collecté!';
    final body = remaining > 0
        ? 'Encore $remaining timbre(s) pour votre récompense chez $shopName'
        : 'Félicitations! Votre carte $shopName est complète!';

    await _showNotification(
      id: 1,
      title: title,
      body: body,
      payload: jsonEncode({
        'type': 'stamp_collected',
        'shopName': shopName,
      }),
    );
  }

  /// Show reward completion notification
  Future<void> showRewardCompletedNotification({
    required String shopName,
    required String rewardName,
  }) async {
    if (!_shouldShowNotification(NotificationType.rewardCompleted)) return;

    await _showNotification(
      id: 2,
      title: '🎉 Récompense débloquée!',
      body: 'Réclamez votre $rewardName chez $shopName',
      payload: jsonEncode({
        'type': 'reward_completed',
        'shopName': shopName,
      }),
    );
  }

  /// Show nearby deal notification
  /// NOTE: Requires backend geofencing or location tracking
  Future<void> showNearbyDealNotification({
    required String shopName,
    required String dealDescription,
    required double distanceKm,
  }) async {
    if (!_shouldShowNotification(NotificationType.nearbyDeal)) return;

    await _showNotification(
      id: 3,
      title: '📍 Offre à proximité!',
      body: '$shopName (${distanceKm.toStringAsFixed(1)}km) - $dealDescription',
      payload: jsonEncode({
        'type': 'nearby_deal',
        'shopName': shopName,
      }),
    );
  }

  /// Show new flyer notification
  Future<void> showNewFlyerNotification({
    required String merchantName,
    required String flyerTitle,
  }) async {
    if (!_shouldShowNotification(NotificationType.newFlyer)) return;

    await _showNotification(
      id: 4,
      title: '📰 Nouveau prospectus!',
      body: '$merchantName: $flyerTitle',
      payload: jsonEncode({
        'type': 'new_flyer',
        'merchantName': merchantName,
      }),
    );
  }

  /// Show expiring offer notification
  /// NOTE: Requires backend to track offer expiration dates
  Future<void> showExpiringOfferNotification({
    required String shopName,
    required String offerName,
    required int hoursRemaining,
  }) async {
    if (!_shouldShowNotification(NotificationType.expiringOffer)) return;

    await _showNotification(
      id: 5,
      title: '⏰ Offre expire bientôt!',
      body: '$offerName chez $shopName expire dans $hoursRemaining heures',
      payload: jsonEncode({
        'type': 'expiring_offer',
        'shopName': shopName,
      }),
    );
  }
}
