part of '../flyers_page.dart';

extension _FlyersPageProductCard on _FlyersPageState {
  Widget _buildProductCard(FlyerProduct product) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxHeight * 0.5).clamp(80.0, 110.0);
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(product, imageHeight),
              Expanded(child: _buildProductInfo(product)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage(FlyerProduct product, double imageHeight) {
    return Container(
      height: imageHeight,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Stack(
        children: [
          Center(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Icon(Icons.image_outlined,
                    size: 40, color: Colors.grey.shade400),
              ),
            ),
          ),
          if (product.discount != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.urgencyOrange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.discount!,
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(FlyerProduct product) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              product.name,
              style: GoogleFonts.poppins(
                color: AppColors.charcoalText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          if (product.oldPrice != null) ...[
            Text(
              product.oldPrice!,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade500,
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
          ],
          Text(
            product.newPrice,
            style: GoogleFonts.poppins(
              color: AppColors.primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
