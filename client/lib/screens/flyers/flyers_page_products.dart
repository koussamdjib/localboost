part of '../flyers_page.dart';

extension _FlyersPageProducts on _FlyersPageState {
  Widget _buildProductsGrid(List<FlyerProduct> products) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) => _buildProductCard(products[index]),
      ),
    );
  }
}
