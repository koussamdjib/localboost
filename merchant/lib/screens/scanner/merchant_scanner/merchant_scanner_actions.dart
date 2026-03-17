part of '../merchant_scanner_screen.dart';

extension _MerchantScannerActions on _MerchantScannerScreenState {
  Future<void> _refreshScannedEnrollment() async {
    final token = _scannedEnrollment?.qrToken;
    if (token == null || token.isEmpty) {
      _resetScanner();
      return;
    }

    final enrollmentProvider = context.read<EnrollmentProvider>();
    final result = await enrollmentProvider.resolveByToken(token);

    if (!mounted) return;

    if (result.success && result.enrollment != null) {
      _setStateSafe(() => _scannedEnrollment = result.enrollment);
    } else {
      _resetScanner();
    }
  }

  Future<void> _handleAddStamp() async {
    if (_scannedEnrollment == null) return;

    // Validate
    final error = ScannerService.validateStampEligibility(_scannedEnrollment!);
    if (error != null) {
      _showError(error);
      return;
    }

    _setStateSafe(() => _isProcessing = true);

    final enrollment = _scannedEnrollment!;
    final idempotencyKey =
        '${enrollment.id}-${DateTime.now().millisecondsSinceEpoch}';

    // --- Offline path ---
    if (!_isOnline) {
      try {
        await _offlineQueue.enqueue(
          OfflineStampAction(
            localUuid: idempotencyKey,
            enrollmentId: enrollment.id,
            qrToken: enrollment.qrToken,
            idempotencyKey: idempotencyKey,
            shopId: widget.shopId,
            shopName: widget.shopName,
            queuedAt: DateTime.now(),
          ),
        );
        if (!mounted) return;
        await ScannerFeedbackDialogs.showOfflineStampQueued(
          context: context,
          shopName: widget.shopName,
        );
        if (mounted) _resetScanner();
      } catch (e) {
        _showError('Erreur mise en file: ${e.toString()}');
      } finally {
        if (mounted) _setStateSafe(() => _isProcessing = false);
      }
      return;
    }

    // --- Online path ---
    try {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      // Use enrollment id + timestamp as idempotency key for this stamp
      final success = await enrollmentProvider.addStamp(
        enrollment.id,
        idempotencyKey,
      );

      if (!mounted) return;

      if (success) {
        await _refreshScannedEnrollment();
        if (!mounted) return;
        final updatedEnrollment = _scannedEnrollment;

        if (updatedEnrollment == null) {
          _showError('Inscription introuvable après mise à jour');
          return;
        }

        await ScannerFeedbackDialogs.showStampSuccess(
          context: context,
          shopName: widget.shopName,
          newStampCount: updatedEnrollment.stampsCollected,
          totalRequired: updatedEnrollment.stampsRequired,
        );
        if (!mounted) return;
      } else {
        _showError(enrollmentProvider.error ?? 'Échec de l\'ajout du timbre');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        _setStateSafe(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleApproveReward() async {
    if (_scannedEnrollment == null) return;

    // Validate
    final error =
        ScannerService.validateApprovalEligibility(_scannedEnrollment!);
    if (error != null) {
      _showError(error);
      return;
    }

    _setStateSafe(() => _isProcessing = true);

    try {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      final requestId = _scannedEnrollment!.rewardRequestId;
      if (requestId == null) {
        _showError('Demande introuvable');
        return;
      }

      final result = await enrollmentProvider.approveRewardRequest(requestId);

      if (!mounted) return;

      if (result.success) {
        await _refreshScannedEnrollment();
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande approuvée')),
        );
      } else {
        _showError(enrollmentProvider.error ?? 'Échec de l\'approbation');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        _setStateSafe(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handleFulfillReward() async {
    if (_scannedEnrollment == null) return;

    final error =
        ScannerService.validateFulfillmentEligibility(_scannedEnrollment!);
    if (error != null) {
      _showError(error);
      return;
    }

    _setStateSafe(() => _isProcessing = true);

    try {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      final requestId = _scannedEnrollment!.rewardRequestId;
      if (requestId == null) {
        _showError('Demande introuvable');
        return;
      }

      final result = await enrollmentProvider.fulfillRewardRequest(requestId);

      if (!mounted) return;

      if (result.success) {
        await ScannerFeedbackDialogs.showRedemptionSuccess(
          context: context,
          shopName: widget.shopName,
        );

        _resetScanner();
      } else {
        _showError(enrollmentProvider.error ?? 'Échec de la validation finale');
      }
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        _setStateSafe(() => _isProcessing = false);
      }
    }
  }

  void _resetScanner() {
    _setStateSafe(() {
      _scannedEnrollment = null;
      _lastScannedCode = null;
      _isProcessing = false;
    });
    if (kIsWeb) _webTokenController.clear();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScannerFeedbackDialogs.showError(context, message);
  }
}
