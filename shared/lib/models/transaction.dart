part 'transaction/transaction_display.dart';

/// Transaction model representing user activity history
class Transaction {
  final String id;
  final String userId;
  final String shopId;
  final String shopName;
  final String shopLogoUrl;
  final TransactionType type;
  final DateTime timestamp;
  final int? stampsAdded; // For stamp collections
  final String? rewardValue; // For redemptions
  final String? merchantNote; // Note from merchant for stamp collection
  final String? location; // Where the transaction occurred

  Transaction({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.shopLogoUrl,
    required this.type,
    required this.timestamp,
    this.stampsAdded,
    this.rewardValue,
    this.merchantNote,
    this.location,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'shopId': shopId,
      'shopName': shopName,
      'shopLogoUrl': shopLogoUrl,
      'type': type.toString(),
      'timestamp': timestamp.toIso8601String(),
      'stampsAdded': stampsAdded,
      'rewardValue': rewardValue,
      'merchantNote': merchantNote,
      'location': location,
    };
  }

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      shopId: json['shopId'] as String,
      shopName: json['shopName'] as String,
      shopLogoUrl: json['shopLogoUrl'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TransactionType.stampCollected,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      stampsAdded: json['stampsAdded'] as int?,
      rewardValue: json['rewardValue'] as String?,
      merchantNote: json['merchantNote'] as String?,
      location: json['location'] as String?,
    );
  }

  /// Copy with method for updates
  Transaction copyWith({
    String? id,
    String? userId,
    String? shopId,
    String? shopName,
    String? shopLogoUrl,
    TransactionType? type,
    DateTime? timestamp,
    int? stampsAdded,
    String? rewardValue,
    String? merchantNote,
    String? location,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      shopLogoUrl: shopLogoUrl ?? this.shopLogoUrl,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      stampsAdded: stampsAdded ?? this.stampsAdded,
      rewardValue: rewardValue ?? this.rewardValue,
      merchantNote: merchantNote ?? this.merchantNote,
      location: location ?? this.location,
    );
  }
}

/// Types of transactions
enum TransactionType {
  stampCollected,
  rewardRedeemed,
  enrolled,
  unenrolled,
}
