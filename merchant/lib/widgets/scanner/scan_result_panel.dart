import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_merchant/services/scanner_service.dart';

part 'panel/scan_result_panel_view.dart';
part 'panel/scan_result_panel_header.dart';
part 'panel/scan_result_panel_progress.dart';
part 'panel/scan_result_panel_status.dart';

/// Panel displaying scan result with customer and program info
class ScanResultPanel extends StatelessWidget {
  final Enrollment enrollment;

  const ScanResultPanel({
    super.key,
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    return _buildScanResultPanel();
  }
}
