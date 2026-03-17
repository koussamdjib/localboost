part of '../deal_card_widget.dart';

extension _DealCardWidgetProgress on DealCardWidget {
  Widget _buildStampProgress(bool isEnrolled, dynamic enrollment) {
    final stampsCollected = isEnrolled && enrollment != null
        ? enrollment.stampsCollected
        : shop.stamps;
    final stampsRequired = isEnrolled && enrollment != null
        ? enrollment.stampsRequired
        : shop.totalRequired;

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: List.generate(
        stampsRequired,
        (index) => Icon(
          index < stampsCollected ? Icons.circle : Icons.circle_outlined,
          size: 16,
          color: index < stampsCollected
              ? AppColors.primaryGreen
              : Colors.grey.shade300,
        ),
      ),
    );
  }
}
