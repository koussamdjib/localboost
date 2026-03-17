part of '../deal_card_widget.dart';

extension _DealCardWidgetBuild on DealCardWidget {
  Widget _buildDealCard(BuildContext context) {
    final enrollmentProvider = Provider.of<EnrollmentProvider>(context);
    final isEnrolled = enrollmentProvider.isEnrolledIn(shop.id);
    final enrollment = enrollmentProvider.getEnrollmentFor(shop.id);

    final isComplete = isEnrolled && enrollment != null
      ? enrollment.stampsCollected >= enrollment.stampsRequired ||
        enrollment.rewardStatus != null
        : (shop.stamps == shop.totalRequired && shop.dealType != 'Deal');

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isListItem
        ? double.infinity
        : (screenWidth * 0.75).clamp(260.0, 320.0);

    return GestureDetector(
      onTap: () => onTap(shop),
      child: Container(
        width: cardWidth,
        decoration: _buildCardDecoration(isComplete),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: isListItem ? MainAxisSize.min : MainAxisSize.max,
          children: [
            _buildShopImage(isComplete),
            if (isListItem)
              _buildCardContent(context, isEnrolled, enrollment)
            else
              Expanded(
                child: _buildCardContent(context, isEnrolled, enrollment),
              ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration(bool isComplete) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isComplete
            ? AppColors.successGreen.withValues(alpha: 0.4)
            : AppColors.primaryGreen.withValues(alpha: 0.1),
        width: isComplete ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: isComplete
              ? AppColors.successGreen.withValues(alpha: 0.2)
              : AppColors.primaryGreen.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildShopImage(bool isComplete) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        image: DecorationImage(
          image: NetworkImage(shop.imageUrl),
          fit: BoxFit.cover,
          onError: (error, stackTrace) {},
        ),
      ),
      child: Stack(
        children: [
          _buildShareButton(),
          _buildShopLogo(),
          if (isComplete) _buildCompletedBadge(),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => ShareHelper.shareOffer(shop),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.share_rounded,
              size: 16,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}
