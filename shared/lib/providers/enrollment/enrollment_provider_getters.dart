part of '../enrollment_provider.dart';

extension EnrollmentProviderGetters on EnrollmentProvider {
  // Get active (non-redeemed) enrollments
  List<Enrollment> get activeEnrollments =>
      _enrollments.where((e) => !e.isRedeemed).toList();

  // Check if user is enrolled in a specific shop
  bool isEnrolledIn(String shopId) {
    return _enrollments.any((e) => e.shopId == shopId && !e.isRedeemed);
  }

  // Get enrollment for a specific shop
  Enrollment? getEnrollmentFor(String shopId) {
    try {
      return _enrollments.firstWhere(
        (e) => e.shopId == shopId && !e.isRedeemed,
      );
    } catch (e) {
      return null;
    }
  }

  // Get enrollment for a specific loyalty program
  Enrollment? getEnrollmentForProgram(String loyaltyProgramId) {
    try {
      return _enrollments.firstWhere(
        (e) => e.loyaltyProgramId == loyaltyProgramId && !e.isRedeemed,
      );
    } catch (e) {
      return null;
    }
  }
}
