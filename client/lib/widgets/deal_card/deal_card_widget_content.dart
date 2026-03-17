part of '../deal_card_widget.dart';

extension _DealCardWidgetContent on DealCardWidget {
  Widget _buildCardContent(
    BuildContext context,
    bool isEnrolled,
    dynamic enrollment,
  ) {
    final int stampsCollected = isEnrolled && enrollment != null
        ? enrollment.stampsCollected
        : shop.stamps;
    final int stampsRequired = isEnrolled && enrollment != null
        ? enrollment.stampsRequired
        : shop.totalRequired;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeaderRow(stampsCollected, stampsRequired),
          const SizedBox(height: 6),
          if (shop.dealType == 'Loyalty') ...[
            _buildStampProgress(isEnrolled, enrollment),
            const SizedBox(height: 8),
          ],
          _buildRewardBadge(),
          if (!isEnrolled && shop.dealType == 'Loyalty') ...[
            const SizedBox(height: 10),
            _buildEnrollButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(int stampsCollected, int stampsRequired) {
    return Row(
      children: [
        Expanded(
          child: Text(
            shop.name,
            style: GoogleFonts.poppins(
              color: AppColors.charcoalText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (shop.dealType == 'Loyalty')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$stampsCollected/$stampsRequired',
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
