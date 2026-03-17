import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';

part 'card/enrollment_card_header_progress.dart';
part 'card/enrollment_card_footer.dart';
part 'card/enrollment_card_helpers.dart';

/// Card widget displaying enrollment summary in list
class EnrollmentCard extends StatelessWidget {
  final Enrollment enrollment;
  final VoidCallback onTap;
  final VoidCallback? onApproveRedemption;
  final VoidCallback? onRejectRedemption;

  const EnrollmentCard({
    super.key,
    required this.enrollment,
    required this.onTap,
    this.onApproveRedemption,
    this.onRejectRedemption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: AppColors.primaryGreen,
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 12),
                          _buildProgress(),
                          const SizedBox(height: 12),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
