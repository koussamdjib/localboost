import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:localboost_shared/services/api/api_exception.dart';

part 'enrollment/enrollment_service_queries.dart';
part 'enrollment/enrollment_service_actions.dart';
part 'enrollment/enrollment_service_rewards.dart';

class EnrollmentService {
  final ApiClient _apiClient = ApiClient.instance;

  // Enroll in a loyalty program
  Future<EnrollmentResult> enroll({
    required String userId,
    required String shopId,
    required String shopName,
    required int stampsRequired,
    String? loyaltyProgramId,
  }) =>
      _enrollImpl(
        service: this,
        userId: userId,
        shopId: shopId,
        shopName: shopName,
        stampsRequired: stampsRequired,
        loyaltyProgramId: loyaltyProgramId,
      );

  // Get all enrollments for a user
  Future<List<Enrollment>> getUserEnrollments(String userId) =>
      _getUserEnrollmentsImpl(service: this, userId: userId);

  // Get all enrollments for a merchant-owned shop
  Future<List<Enrollment>> getShopEnrollments(String shopId) =>
      _getShopEnrollmentsImpl(service: this, shopId: shopId);

  // Check if user is enrolled in a specific shop
  Future<Enrollment?> getEnrollment(String userId, String shopId) =>
      _getEnrollmentImpl(service: this, userId: userId, shopId: shopId);

  // Unenroll from a loyalty program
  Future<bool> unenroll(String enrollmentId) =>
      _unenrollImpl(service: this, enrollmentId: enrollmentId);

  // Add a stamp to an enrollment (called when merchant scans QR)
  Future<EnrollmentResult> addStamp({
    required String enrollmentId,
    required String idempotencyKey,
  }) =>
      _addStampImpl(service: this, enrollmentId: enrollmentId, idempotencyKey: idempotencyKey);

  // Resolve a QR token to an enrollment (merchant scanner)
  Future<EnrollmentResult> resolveByToken(String qrToken) =>
      _resolveByTokenImpl(service: this, qrToken: qrToken);

  // --- Reward lifecycle ---

  /// Customer: create a reward request (requested state).
  Future<RewardRequestResult> requestReward(String enrollmentId) =>
      _requestRewardImpl(service: this, enrollmentId: enrollmentId);

  /// Get reward requests visible to the caller (customer: own; merchant: shop).
  Future<List<RewardRequest>> getRewardRequests({
    String? status,
    String? shopId,
    String? enrollmentId,
  }) =>
      _getRewardRequestsImpl(
        service: this,
        status: status,
        shopId: shopId,
        enrollmentId: enrollmentId,
      );

  /// Merchant: approve a reward request.
  Future<RewardRequestResult> approveRewardRequest(int rewardRequestId) =>
      _approveRewardRequestImpl(
          service: this, rewardRequestId: rewardRequestId);

  /// Merchant: reject a reward request.
  Future<RewardRequestResult> rejectRewardRequest(int rewardRequestId) =>
      _rejectRewardRequestImpl(
          service: this, rewardRequestId: rewardRequestId);

  /// Merchant: fulfill an approved reward request.
  Future<RewardRequestResult> fulfillRewardRequest(int rewardRequestId) =>
      _fulfillRewardRequestImpl(
          service: this, rewardRequestId: rewardRequestId);

  List<Enrollment> parseEnrollmentList(dynamic payload) {
    final rawList = _extractListPayload(payload);

    return rawList
        .whereType<Map>()
        .map(
          (item) => Enrollment.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
  }

  Enrollment? parseEnrollment(dynamic payload) {
    if (payload is! Map) {
      return null;
    }

    return Enrollment.fromJson(Map<String, dynamic>.from(payload));
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final results = map['results'];
      if (results is List) {
        return results;
      }

      final data = map['data'];
      if (data is List) {
        return data;
      }
    }

    return const <dynamic>[];
  }

  String toReadableApiError(Object error) {
    if (error is ValidationException) {
      return error.allFieldErrors;
    }
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}

// Result wrapper class
class EnrollmentResult {
  final bool success;
  final Enrollment? enrollment;
  final String? error;
  final String? message;

  EnrollmentResult({
    required this.success,
    this.enrollment,
    this.error,
    this.message,
  });
}

