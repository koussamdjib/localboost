part of '../enrollment_provider.dart';

extension EnrollmentProviderRewards on EnrollmentProvider {
  // Add a stamp (called when merchant scans QR)
  Future<bool> addStamp(String enrollmentId, String idempotencyKey) async {
    try {
      final result = await _enrollmentService.addStamp(
        enrollmentId: enrollmentId,
        idempotencyKey: idempotencyKey,
      );

      if (result.success && result.enrollment != null) {
        final index = _enrollments.indexWhere((e) => e.id == enrollmentId);
        if (index != -1) {
          _enrollments[index] = result.enrollment!;
        }
        _error = null;
        _notifyStateChanged();
        return true;
      }

      _error = result.error ?? 'Erreur d\'ajout de timbre';
      _notifyStateChanged();
      return false;
    } catch (e) {
      _error = 'Erreur d\'ajout de timbre: $e';
      _notifyStateChanged();
      return false;
    }
  }

  /// Customer: submit a reward request (requested state).
  Future<RewardRequestResult> requestReward(String enrollmentId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result = await _enrollmentService.requestReward(enrollmentId);
      if (!result.success) {
        _error = result.error ?? 'Erreur lors de la demande de récompense';
      }
      return result;
    } catch (e) {
      _error = 'Erreur lors de la demande de récompense: $e';
      return RewardRequestResult(success: false, error: _error);
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  /// Merchant: list reward requests (optionally filtered by status/shop).
  Future<List<RewardRequest>> fetchRewardRequests({
    String? status,
    String? shopId,
    String? enrollmentId,
  }) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final requests = await _enrollmentService.getRewardRequests(
        status: status,
        shopId: shopId,
        enrollmentId: enrollmentId,
      );
      return requests;
    } catch (e) {
      _error = 'Erreur lors du chargement des demandes: $e';
      return [];
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  /// Merchant: approve a reward request.
  Future<RewardRequestResult> approveRewardRequest(int rewardRequestId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result =
          await _enrollmentService.approveRewardRequest(rewardRequestId);
      if (!result.success) {
        _error = result.error ?? 'Erreur lors de l\'approbation';
      }
      return result;
    } catch (e) {
      _error = 'Erreur lors de l\'approbation: $e';
      return RewardRequestResult(success: false, error: _error);
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  /// Merchant: reject a reward request.
  Future<RewardRequestResult> rejectRewardRequest(int rewardRequestId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result =
          await _enrollmentService.rejectRewardRequest(rewardRequestId);
      if (!result.success) {
        _error = result.error ?? 'Erreur lors du rejet';
      }
      return result;
    } catch (e) {
      _error = 'Erreur lors du rejet: $e';
      return RewardRequestResult(success: false, error: _error);
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

  /// Merchant: fulfill an approved reward request.
  Future<RewardRequestResult> fulfillRewardRequest(int rewardRequestId) async {
    _isLoading = true;
    _error = null;
    _notifyStateChanged();

    try {
      final result =
          await _enrollmentService.fulfillRewardRequest(rewardRequestId);
      if (!result.success) {
        _error = result.error ?? 'Erreur lors de la fulfillment';
      }
      return result;
    } catch (e) {
      _error = 'Erreur lors de la fulfillment: $e';
      return RewardRequestResult(success: false, error: _error);
    } finally {
      _isLoading = false;
      _notifyStateChanged();
    }
  }

}

