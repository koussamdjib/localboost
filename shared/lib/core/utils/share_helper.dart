import 'package:share_plus/share_plus.dart';
import 'package:localboost_shared/models/shop.dart';

/// Utility class for sharing deals and offers with proper French text formatting
class ShareHelper {
  /// Share a shop/deal with formatted text
  static Future<void> shareOffer(Shop shop) async {
    final shareText = _formatShareText(shop);

    try {
      await Share.share(
        shareText,
        subject: 'Découvrez cette offre LocalBoost !',
      );
    } catch (e) {
      // Share failed silently - user canceled or not supported
      // In production, you might want to log this
    }
  }

  /// Format shop data into readable French share text
  static String _formatShareText(Shop shop) {
    final buffer = StringBuffer();

    // Header with emoji
    buffer.writeln('🎉 Découvrez cette offre LocalBoost !');
    buffer.writeln();

    // Merchant name
    buffer.writeln('📍 ${shop.name}');
    buffer.writeln('   ${shop.location}');
    buffer.writeln();

    // Deal type and progress
    if (shop.dealType == 'Flash Sale') {
      buffer.writeln('⚡ OFFRE FLASH - ${shop.timeLeft}');
    } else if (shop.dealType == 'Loyalty') {
      buffer.writeln('💳 Programme de fidélité');
      if (shop.stamps > 0) {
        buffer.writeln(
            '   Progression : ${shop.stamps}/${shop.totalRequired} timbres');
      }
    } else if (shop.dealType == 'Deal') {
      buffer.writeln('🎁 Offre spéciale');
      if (shop.timeLeft.isNotEmpty) {
        buffer.writeln('   Expire dans ${shop.timeLeft}');
      }
    }
    buffer.writeln();

    // Reward
    buffer.writeln('${shop.rewardIcon} Récompense : ${shop.rewardValue}');
    buffer.writeln();

    // Call to action
    buffer.writeln(
        'Téléchargez LocalBoost pour profiter de cette offre et bien d\'autres !');

    // Future: Add deep link here when ready
    // buffer.writeln('localboost://shop/${shop.id}');

    return buffer.toString();
  }

  /// Share with additional context (e.g., from detail page with stamps info)
  static Future<void> shareOfferDetailed(Shop shop,
      {String? additionalMessage}) async {
    var shareText = _formatShareText(shop);

    if (additionalMessage != null && additionalMessage.isNotEmpty) {
      shareText = '$additionalMessage\n\n$shareText';
    }

    try {
      await Share.share(
        shareText,
        subject: 'Découvrez ${shop.name} sur LocalBoost !',
      );
    } catch (e) {
      // Share failed silently
    }
  }
}
