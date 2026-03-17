part of '../merchant_scanner_screen.dart';

extension _MerchantScannerWebInput on _MerchantScannerScreenState {
  /// Web fallback: manual QR token entry with a text field.
  Widget _buildWebManualInput() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isOnline) _buildOfflineBanner(),
          Expanded(
            child: _scannedEnrollment != null
                ? _buildResultView()
                : _buildWebInputForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildWebInputForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Saisie QR manuelle',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'La caméra n\'est pas disponible sur navigateur web.\n'
                'Copiez-collez le token QR du client.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _webTokenController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Token QR',
                  hintText: 'Collez le token ici…',
                  prefixIcon:
                      const Icon(Icons.token_rounded, color: AppColors.primaryGreen),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: AppColors.primaryGreen, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSubmitted: (_) => _submitWebToken(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _submitWebToken,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  label: Text(
                    _isProcessing ? 'Recherche…' : 'Rechercher le client',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitWebToken() async {
    final raw = _webTokenController.text.trim();
    if (raw.isEmpty) return;

    final qrToken = ScannerService.parseEnrollmentToken(raw);
    if (qrToken == null || !ScannerService.isValidQrCode(raw)) {
      _showError('Token QR invalide');
      return;
    }

    _setStateSafe(() {
      _isProcessing = true;
      _lastScannedCode = raw;
    });

    try {
      final enrollmentProvider = context.read<EnrollmentProvider>();
      final result = await enrollmentProvider.resolveByToken(qrToken);

      if (!mounted) return;

      if (!result.success || result.enrollment == null) {
        _showError(result.error ?? 'Token non reconnu');
        return;
      }

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
