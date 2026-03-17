part of '../enrollment_provider.dart';

extension EnrollmentProviderAccountActions on EnrollmentProvider {
  // Load enrollments for a user
  Future<void> loadEnrollments(String userId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      _enrollments = await _enrollmentService.getUserEnrollments(userId);
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement des inscriptions: $e';
      _enrollments = [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  // Load enrollments for a merchant shop.
  Future<void> loadShopEnrollments(String shopId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      _enrollments = await _enrollmentService.getShopEnrollments(shopId);
      _error = null;
    } catch (e) {
      _error = 'Erreur de chargement des clients: $e';
      _enrollments = [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  // Enroll in a loyalty program
  Future<bool> enroll({
    required String userId,
    required String shopId,
    required String shopName,
    required int stampsRequired,
    String? loyaltyProgramId,
  }) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _enrollmentService.enroll(
        userId: userId,
        shopId: shopId,
        shopName: shopName,
        stampsRequired: stampsRequired,
        loyaltyProgramId: loyaltyProgramId,
      );

      if (result.success && result.enrollment != null) {
        _enrollments.insert(0, result.enrollment!);
        _error = null;
        _notifyStateChanged();
        return true;
      } else {
        _error = result.error ?? 'Erreur d\'inscription';
        _notifyStateChanged();
        return false;
      }
    } catch (e) {
      _error = 'Erreur d\'inscription: $e';
      _notifyStateChanged();
      return false;
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  // Resolve a QR token to an enrollment (merchant scanner)
  Future<EnrollmentResult> resolveByToken(String qrToken) async {
    try {
      return await _enrollmentService.resolveByToken(qrToken);
    } catch (e) {
      return EnrollmentResult(success: false, error: 'Erreur: $e');
    }
  }

}
