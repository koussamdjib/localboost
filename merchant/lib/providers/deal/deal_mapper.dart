import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_shared/services/api/api_config.dart';

/// Pure data-mapping functions for converting between API JSON and Deal models.
/// All methods are static — no instance state.
class DealMapper {
  DealMapper._();

  /// Convert an API JSON map to a [Deal] domain object.
  static Deal fromApi(Map<String, dynamic> json) {
    final nowUtc = DateTime.now().toUtc();
    final id = _toStringValue(json['id']);
    final shopId = _toStringValue(json['shop_id']);
    final startsAt = _parseDateTime(json['starts_at'], fallback: nowUtc);
    final endsAt = _parseDateTime(
      json['ends_at'],
      fallback: startsAt.add(const Duration(days: 30)),
    );
    final apiStatus = _toStringValue(json['status']).toLowerCase();
    final dealType = _dealTypeFromApi(_toStringValue(json['deal_type']).toLowerCase());
    final status = _dealStatusFromApi(apiStatus: apiStatus, endsAt: endsAt);

    return Deal(
      id: id,
      shopId: shopId,
      title: _toStringValue(json['title']),
      description: _toStringValue(json['description']),
      dealType: dealType,
      stampsRequired: dealType == DealType.loyalty ? 10 : 0,
      rewardValue: _defaultRewardValue(dealType),
      rewardType: _defaultRewardType(dealType),
      imageUrl: _resolveImageUrl(json['image']),
      termsAndConditions: '',
      startDate: startsAt.toLocal(),
      endDate: endsAt.toLocal(),
      status: status,
      maxEnrollments: _toIntValue(json['max_redemptions']),
      enrollmentCount: _toIntValue(json['enrollment_count']) ?? 0,
      redemptionCount: _toIntValue(json['redemption_count']) ?? 0,
      viewCount: _toIntValue(json['view_count']) ?? 0,
      shareCount: _toIntValue(json['share_count']) ?? 0,
      createdAt: _parseDateTime(json['created_at'], fallback: nowUtc).toLocal(),
    );
  }

  /// Convert a [Deal] to the API JSON payload for create/update requests.
  static Map<String, dynamic> toPayload(Deal deal) {
    return <String, dynamic>{
      'title': deal.title,
      'description': deal.description,
      'deal_type': _dealTypeToApi(deal.dealType),
      'status': _dealStatusToApi(deal.status),
      'starts_at': deal.startDate.toUtc().toIso8601String(),
      'ends_at': deal.endDate.toUtc().toIso8601String(),
      'max_redemptions': deal.maxEnrollments,
    };
  }

  // ── Type converters ────────────────────────────────────────────────────────

  static DealType _dealTypeFromApi(String apiType) {
    switch (apiType) {
      case 'stamp':
        return DealType.loyalty;
      case 'percentage':
        return DealType.flashSale;
      default:
        return DealType.standard;
    }
  }

  static String _dealTypeToApi(DealType dealType) {
    switch (dealType) {
      case DealType.loyalty:
        return 'stamp';
      case DealType.flashSale:
        return 'percentage';
      case DealType.standard:
        return 'amount';
    }
  }

  static DealStatus _dealStatusFromApi({
    required String apiStatus,
    required DateTime endsAt,
  }) {
    final nowUtc = DateTime.now().toUtc();
    if (apiStatus == 'archived') return DealStatus.expired;
    if (endsAt.isBefore(nowUtc)) return DealStatus.expired;
    if (apiStatus == 'published') return DealStatus.active;
    return DealStatus.draft;
  }

  static String _dealStatusToApi(DealStatus status) {
    switch (status) {
      case DealStatus.active:
        return 'published';
      case DealStatus.expired:
        return 'archived';
      case DealStatus.draft:
        return 'draft';
    }
  }

  static RewardType _defaultRewardType(DealType dealType) {
    switch (dealType) {
      case DealType.loyalty:
        return RewardType.freeItem;
      case DealType.flashSale:
      case DealType.standard:
        return RewardType.discount;
    }
  }

  static String _defaultRewardValue(DealType dealType) {
    switch (dealType) {
      case DealType.loyalty:
        return 'Recompense fidelite';
      case DealType.flashSale:
        return 'Remise en pourcentage';
      case DealType.standard:
        return 'Remise fixe';
    }
  }

  // ── Raw value helpers ──────────────────────────────────────────────────────

  static DateTime _parseDateTime(dynamic rawValue, {required DateTime fallback}) {
    if (rawValue is String) {
      final parsed = DateTime.tryParse(rawValue);
      if (parsed != null) return parsed.toUtc();
    }
    return fallback;
  }

  static int? _toIntValue(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String _toStringValue(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _resolveImageUrl(dynamic imageValue) {
    final imagePath = _toStringValue(imageValue).trim();
    if (imagePath.isEmpty) return null;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    final baseUri = Uri.parse(ApiConfig.normalizedBaseUrl);
    if (imagePath.startsWith('/')) {
      return Uri(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.hasPort ? baseUri.port : null,
        path: imagePath,
      ).toString();
    }
    return baseUri.resolve(imagePath).toString();
  }
}
