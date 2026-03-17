part of '../merchant_scanner_screen.dart';

extension _MerchantScannerBarcodeHandler on _MerchantScannerScreenState {
  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing || _scannedEnrollment != null) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code == _lastScannedCode) return;

    _setStateSafe(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    try {
      // Validate token is non-empty
      final qrToken = ScannerService.parseEnrollmentToken(code);
      if (qrToken == null || !ScannerService.isValidQrCode(code)) {
        _showError('QR code invalide');
        return;
      }

      if (!mounted) return;

      // Resolve token via API
      final enrollmentProvider = context.read<EnrollmentProvider>();
      final result = await enrollmentProvider.resolveByToken(qrToken);

      if (!mounted) return;

      if (!result.success || result.enrollment == null) {
        _showError(result.error ?? 'QR code non reconnu');
        return;
      }

      // Show result panel
      _setStateSafe(() {
        _scannedEnrollment = result.enrollment;
        _isProcessing = false;
      });
    } catch (e) {
      _showError('Erreur: ${e.toString()}');
    } finally {
      if (_scannedEnrollment == null) {
        _setStateSafe(() {
          _isProcessing = false;
          _lastScannedCode = null;
        });
      }
    }
  }
}
