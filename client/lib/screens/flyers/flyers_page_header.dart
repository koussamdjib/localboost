part of '../flyers_page.dart';

extension _FlyersPageHeader on _FlyersPageState {
  Widget _buildFlyerHeader(Flyer flyer, bool isRecent) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStoreLogo(flyer),
          const SizedBox(width: 12),
          Expanded(child: _buildStoreInfo(flyer)),
          const SizedBox(width: 8),
          isRecent ? _buildRecentBadge() : _buildDistanceBadge(flyer),
        ],
      ),
    );
  }

  Widget _buildStoreLogo(Flyer flyer) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          flyer.storeLogoUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              flyer.storeName[0],
              style: GoogleFonts.poppins(
                color: AppColors.primaryGreen,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo(Flyer flyer) {
    final isPdf = flyer.fileType == FlyerType.pdf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                flyer.storeName,
                style: GoogleFonts.poppins(
                  color: AppColors.charcoalText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isPdf ? Colors.red.shade50 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isPdf ? Colors.red.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.image,
                    size: 10,
                    color: isPdf ? Colors.red.shade700 : Colors.blue.shade700,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    flyer.fileType.displayName,
                    style: GoogleFonts.poppins(
                      color: isPdf ? Colors.red.shade700 : Colors.blue.shade700,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          flyer.title,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
