import 'dart:convert';

/// A stamp action queued for later sync when the device is offline.
class OfflineStampAction {
  final String localUuid;
  final String enrollmentId;
  final String qrToken;
  final String idempotencyKey;
  final String shopId;
  final String shopName;
  final DateTime queuedAt;

  const OfflineStampAction({
    required this.localUuid,
    required this.enrollmentId,
    required this.qrToken,
    required this.idempotencyKey,
    required this.shopId,
    required this.shopName,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() => {
        'localUuid': localUuid,
        'enrollmentId': enrollmentId,
        'qrToken': qrToken,
        'idempotencyKey': idempotencyKey,
        'shopId': shopId,
        'shopName': shopName,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory OfflineStampAction.fromJson(Map<String, dynamic> json) =>
      OfflineStampAction(
        localUuid: json['localUuid'] as String,
        enrollmentId: json['enrollmentId'] as String,
        qrToken: json['qrToken'] as String,
        idempotencyKey: json['idempotencyKey'] as String,
        shopId: json['shopId'] as String,
        shopName: json['shopName'] as String,
        queuedAt: DateTime.parse(json['queuedAt'] as String),
      );

  String toJsonString() => jsonEncode(toJson());

  static OfflineStampAction fromJsonString(String s) =>
      OfflineStampAction.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
