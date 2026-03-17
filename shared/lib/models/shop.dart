import 'stamp_history.dart';

/// Shop model representing a business with loyalty/deal program
class Shop {
  final String id;
  final String? enrollmentId;
  final String? loyaltyProgramId;
  final String name;
  final int stamps;
  final int totalRequired;
  final String dealType; // 'Flash Sale', 'Loyalty', or 'Deal'
  final String timeLeft;
  final String location;
  final String rewardValue;
  final String rewardType; // 'free_item', 'discount', 'money', 'special_offer'
  final String imageUrl;
  final String logoUrl;
  final double latitude;
  final double longitude;
  final List<StampHistory>? history; // Optional: stamp collection history
  final bool isRedeemed; // Whether the reward has been redeemed

  Shop({
    required this.id,
    this.enrollmentId,
    this.loyaltyProgramId,
    required this.name,
    required this.stamps,
    required this.totalRequired,
    required this.dealType,
    required this.timeLeft,
    required this.location,
    required this.rewardValue,
    required this.rewardType,
    required this.imageUrl,
    required this.logoUrl,
    required this.latitude,
    required this.longitude,
    this.history,
    this.isRedeemed = false,
  });

  String get rewardIcon {
    switch (rewardType) {
      case 'free_item':
        return '🎁';
      case 'discount':
        return '💰';
      case 'money':
        return '💵';
      case 'special_offer':
        return '⭐';
      default:
        return '🎉';
    }
  }

  /// Get remaining stamps needed to complete the reward
  int get remainingStamps => (totalRequired - stamps).clamp(0, totalRequired);

  /// Check if the loyalty card is complete
  bool get isComplete => stamps >= totalRequired;

  /// Get progress percentage
  double get progressPercentage => stamps / totalRequired;
}
