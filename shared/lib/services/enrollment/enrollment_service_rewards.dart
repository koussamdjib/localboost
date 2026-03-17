part of '../enrollment_service.dart';

/// Reward request models for the service layer.
class RewardRequest {
  final int id;
  final int enrollmentId;
  final String shopId;
  final String shopName;
  final String customerUserId;
  final String rewardLabel;
  final String status;
  final String? approvedByUserId;
  final DateTime requestedAt;
  final DateTime? redeemedAt;

  RewardRequest({
    required this.id,
    required this.enrollmentId,
    required this.shopId,
    required this.shopName,
    required this.customerUserId,
    required this.rewardLabel,
    required this.status,
    this.approvedByUserId,
    required this.requestedAt,
    this.redeemedAt,
  });

  factory RewardRequest.fromJson(Map<String, dynamic> json) {
    return RewardRequest(
      id: json['id'] as int,
      enrollmentId: json['enrollment_id'] as int,
      shopId: (json['shop_id'] ?? '').toString(),
      shopName: (json['shop_name'] as String?) ?? '',
      customerUserId: (json['customer_user_id'] as String?) ?? '',
      rewardLabel: (json['reward_label'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      approvedByUserId: json['approved_by_user_id'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : DateTime.now(),
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'] as String)
          : null,
    );
  }
}

class RewardRequestResult {
  final bool success;
  final RewardRequest? rewardRequest;
  final String? error;

  RewardRequestResult({required this.success, this.rewardRequest, this.error});
}

RewardRequestResult _parseRewardRequestResult(dynamic payload) {
  if (payload is! Map) {
    return RewardRequestResult(
      success: false,
      error: 'Réponse invalide du serveur.',
    );
  }

  final request = RewardRequest.fromJson(Map<String, dynamic>.from(payload));
  return RewardRequestResult(success: true, rewardRequest: request);
}

Future<RewardRequestResult> _postRewardAction({
  required EnrollmentService service,
  required String path,
}) async {
  try {
    final response = await service._apiClient.post(
      path,
      data: const <String, dynamic>{},
    );
    return _parseRewardRequestResult(response.data);
  } catch (error) {
    return RewardRequestResult(
      success: false,
      error: service.toReadableApiError(error),
    );
  }
}

Future<RewardRequestResult> _requestRewardImpl({
  required EnrollmentService service,
  required String enrollmentId,
}) async {
  try {
    final response = await service._apiClient.post(
      'rewards/requests/',
      data: <String, dynamic>{'enrollment_id': int.parse(enrollmentId)},
    );
    return _parseRewardRequestResult(response.data);
  } catch (error) {
    return RewardRequestResult(
        success: false, error: service.toReadableApiError(error));
  }
}

Future<List<RewardRequest>> _getRewardRequestsImpl({
  required EnrollmentService service,
  String? status,
  String? shopId,
  String? enrollmentId,
}) async {
  final params = <String, dynamic>{};
  if (status != null) params['status'] = status;
  if (shopId != null) params['shop_id'] = shopId;
  if (enrollmentId != null) params['enrollment_id'] = enrollmentId;

  final response = await service._apiClient.get(
    'rewards/requests/',
    queryParameters: params.isNotEmpty ? params : null,
  );

  final raw = response.data;
  List<dynamic> list;
  if (raw is List) {
    list = raw;
  } else if (raw is Map) {
    final m = Map<String, dynamic>.from(raw);
    list = (m['results'] ?? m['data'] ?? []) as List<dynamic>;
  } else {
    list = [];
  }

  return list
      .whereType<Map>()
      .map((e) => RewardRequest.fromJson(Map<String, dynamic>.from(e)))
      .toList(growable: false);
}

Future<RewardRequestResult> _approveRewardRequestImpl({
  required EnrollmentService service,
  required int rewardRequestId,
}) async {
  return _postRewardAction(
    service: service,
    path: 'rewards/requests/$rewardRequestId/approve/',
  );
}

Future<RewardRequestResult> _rejectRewardRequestImpl({
  required EnrollmentService service,
  required int rewardRequestId,
}) async {
  return _postRewardAction(
    service: service,
    path: 'rewards/requests/$rewardRequestId/reject/',
  );
}

Future<RewardRequestResult> _fulfillRewardRequestImpl({
  required EnrollmentService service,
  required int rewardRequestId,
}) async {
  return _postRewardAction(
    service: service,
    path: 'rewards/requests/$rewardRequestId/fulfill/',
  );
}
