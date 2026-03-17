import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';

part 'qr_code/qr_code_screen_view.dart';
part 'qr_code/qr_code_screen_sections.dart';

class QRCodeScreen extends StatelessWidget {
  final Enrollment enrollment;

  const QRCodeScreen({super.key, required this.enrollment});

  @override
  Widget build(BuildContext context) {
    return _buildQrCodeScaffold(context);
  }
}
