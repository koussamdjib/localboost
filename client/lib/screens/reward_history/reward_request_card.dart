import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/services/enrollment_service.dart';

String _statusLabel(String status) {
  switch (status) {
    case 'requested':
      return 'En attente';
    case 'approved':
      return 'Approuvée';
    case 'rejected':
      return 'Rejetée';
    case 'fulfilled':
      return 'Validée';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'requested':
      return AppColors.urgencyOrange;
    case 'approved':
      return AppColors.primaryGreen;
    case 'rejected':
      return Colors.red.shade600;
    case 'fulfilled':
      return AppColors.successGreen;
    default:
      return Colors.grey.shade600;
  }
}

IconData _statusIcon(String status) {
  switch (status) {
    case 'requested':
      return Icons.pending_outlined;
    case 'approved':
      return Icons.check_circle_outline;
    case 'rejected':
      return Icons.cancel_outlined;
    case 'fulfilled':
      return Icons.verified_outlined;
    default:
      return Icons.info_outline;
  }
}

String _formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString();
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/$year a $hour:$minute';
}

/// Card displaying a single reward request with status, shop, reward, and dates.
class RewardRequestCard extends StatelessWidget {
  final RewardRequest request;

  const RewardRequestCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon(request.status),
                  color: statusColor, size: 18),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(request.status),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '#${request.id}',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            request.shopName,
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.rewardLabel,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Demandee le ${_formatDateTime(request.requestedAt)}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (request.redeemedAt != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.verified,
                    size: 14, color: AppColors.successGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Validee le ${_formatDateTime(request.redeemedAt!)}',
                    style: GoogleFonts.poppins(
                      color: AppColors.successGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
