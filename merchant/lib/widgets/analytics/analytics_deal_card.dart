import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_section_widgets.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';

/// Card showing deal analytics: views, enrollments, redemptions, shares,
/// conversion rate progress bar.
class AnalyticsDealCard extends StatelessWidget {
  final Deal deal;
  const AnalyticsDealCard({super.key, required this.deal});

  @override
  Widget build(BuildContext context) {
    final views = deal.viewCount;
    final enrollments = deal.enrollmentCount;
    final redemptions = deal.redemptionCount;
    final shares = deal.shareCount;
    final conversionPct =
        enrollments > 0 ? (redemptions / enrollments).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  deal.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoalText,
                  ),
                ),
              ),
              AnalyticsStatusChip(status: deal.status.name),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AnalyticsStatBadge(icon: Icons.visibility, value: views, label: 'Vues', color: Colors.blue),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.people, value: enrollments, label: 'Inscrits', color: Colors.orange),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.check_circle, value: redemptions, label: 'Utilisés', color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              AnalyticsStatBadge(icon: Icons.share, value: shares, label: 'Partagés', color: Colors.purple),
            ],
          ),
          if (enrollments > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Taux de conversion : ',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                Text(
                  '${(conversionPct * 100).toStringAsFixed(0)} %',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: conversionPct,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
          ],
        ],
      ),
    );
  }
}
