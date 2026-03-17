import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/services/connectivity_service.dart';
import 'package:localboost_merchant/services/offline_queue_service.dart';
import 'package:localboost_merchant/models/offline_stamp_action.dart';
import 'package:localboost_merchant/services/scanner_service.dart';
import 'package:localboost_merchant/widgets/scanner/scan_result_panel.dart';
import 'package:localboost_merchant/widgets/scanner/scanner_action_buttons.dart';
import 'package:localboost_merchant/widgets/scanner/scanner_camera_widget.dart';
import 'package:localboost_merchant/widgets/scanner/scanner_feedback_dialogs.dart';

part 'merchant_scanner/merchant_scanner_barcode_handler.dart';
part 'merchant_scanner/merchant_scanner_actions.dart';
part 'merchant_scanner/merchant_scanner_view.dart';
part 'merchant_scanner/merchant_scanner_web_input.dart';

/// Merchant scanner screen for adding stamps and redeeming rewards
class MerchantScannerScreen extends StatefulWidget {
  final String shopId;
  final String shopName;

  const MerchantScannerScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  State<MerchantScannerScreen> createState() => _MerchantScannerScreenState();
}

class _MerchantScannerScreenState extends State<MerchantScannerScreen> {
  // Camera controller: only used on non-web platforms.
  late final MobileScannerController _controller;

  // Web fallback: manual token input.
  final TextEditingController _webTokenController = TextEditingController();

  final OfflineQueueService _offlineQueue = OfflineQueueService();
  final ConnectivityService _connectivity = ConnectivityService();

  bool _isOnline = true;
  bool _isProcessing = false;
  String? _lastScannedCode;
  Enrollment? _scannedEnrollment;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    }
    _connectivity.isOnline.then((online) {
      if (mounted) setState(() => _isOnline = online);
    });
    _connectivity.onlineStream.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    if (!kIsWeb) _controller.dispose();
    _webTokenController.dispose();
    super.dispose();
  }

  void _setStateSafe(VoidCallback fn) {
    if (!mounted) {
      return;
    }
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _buildWebManualInput();
    return _buildMerchantScannerScreen();
  }
}
