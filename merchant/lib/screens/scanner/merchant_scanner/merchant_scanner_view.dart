part of '../merchant_scanner_screen.dart';

// ignore_for_file: unused_element — _buildAppBar/_buildOfflineBanner also used by web part

extension _MerchantScannerView on _MerchantScannerScreenState {
  Widget _buildMerchantScannerScreen() {
    return Scaffold(
      backgroundColor: _scannedEnrollment != null ? Colors.white : Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isOnline) _buildOfflineBanner(),
          Expanded(
            child: _scannedEnrollment != null
                ? _buildResultView()
                : _buildScannerView(),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hors ligne — les timbres seront synchronisés au retour du réseau',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _scannedEnrollment != null ? Colors.white : Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.close,
          color: _scannedEnrollment != null
              ? AppColors.charcoalText
              : Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode Commerçant',
            style: GoogleFonts.poppins(
              color: _scannedEnrollment != null
                  ? AppColors.charcoalText
                  : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          Text(
            widget.shopName,
            style: GoogleFonts.poppins(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: _scannedEnrollment == null && !kIsWeb
          ? [
              IconButton(
                icon: Icon(
                  _controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () => _controller.toggleTorch(),
              ),
              IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: () => _controller.switchCamera(),
              ),
            ]
          : null,
    );
  }

  Widget _buildScannerView() {
    return ScannerCameraWidget(
      controller: _controller,
      onDetect: _handleBarcode,
      isProcessing: _isProcessing,
    );
  }

  Widget _buildResultView() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScanResultPanel(
                    enrollment: _scannedEnrollment!,
                  ),
                  const SizedBox(height: 20),
                  ScannerActionButtons(
                    enrollment: _scannedEnrollment!,
                    onAddStamp: _handleAddStamp,
                    onApproveReward: _handleApproveReward,
                    onFulfillReward: _handleFulfillReward,
                    onCancel: _resetScanner,
                    isProcessing: _isProcessing,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
