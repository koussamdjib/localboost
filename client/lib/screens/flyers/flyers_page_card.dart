part of '../flyers_page.dart';

extension _FlyersPageCard on _FlyersPageState {
  Widget _buildFlyerCard(Flyer flyer) {
    final isRecent = DateTime.now().difference(flyer.publishedDate).inDays <= 3;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FlyerDetailPage(flyer: flyer)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlyerHeader(flyer, isRecent),
            const Divider(height: 1),
            if (flyer.products != null) _buildProductsGrid(flyer.products!),
            _buildFlyerFooter(flyer),
          ],
        ),
      ),
    );
  }
}
