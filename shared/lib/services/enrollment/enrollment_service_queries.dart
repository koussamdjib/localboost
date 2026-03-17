part of '../enrollment_service.dart';

Future<List<Enrollment>> _getUserEnrollmentsImpl({
  required EnrollmentService service,
  required String userId,
}) async {
  final response = await service._apiClient.get('enrollments/');
  return service.parseEnrollmentList(response.data);
}

Future<List<Enrollment>> _getShopEnrollmentsImpl({
  required EnrollmentService service,
  required String shopId,
}) async {
  final response = await service._apiClient.get(
    'enrollments/',
    queryParameters: <String, dynamic>{'shop_id': shopId},
  );
  return service.parseEnrollmentList(response.data);
}

Future<Enrollment?> _getEnrollmentImpl({
  required EnrollmentService service,
  required String userId,
  required String shopId,
}) async {
  try {
    final enrollments = await service.getUserEnrollments(userId);
    return enrollments.firstWhere(
      (e) => e.shopId == shopId && !e.isRedeemed,
      orElse: () => throw Exception('Not enrolled'),
    );
  } catch (e) {
    return null;
  }
}

Future<bool> _unenrollImpl({
  required EnrollmentService service,
  required String enrollmentId,
}) async {
  await service._apiClient.delete('enrollments/$enrollmentId/');
  return true;
}
