content = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_info_cards.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_progress_ring.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_reward_button.dart';
import 'package:localboost_client/screens/my_card_detail/card_detail_stamp_history.dart';

/// Full-screen loyalty card detail page.
class MyCardDetailPage extends StatelessWidget {
  final Shop shop;

  const MyCardDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                CardDetailProgressRing(shop: shop),
                const SizedBox(height: 12),
                CardDetailRewardInfo(shop: shop),
                if (shop.history != null && shop.history!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  CardDetailStampHistory(shop: shop),
                ],
                const SizedBox(height: 12),
                CardDetailShopInfo(shop: shop),
                if (shop.isComplete && !shop.isRedeemed) ...[
                  const SizedBox(height: 16),
                  CardDetailRewardButton(shop: shop),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      title: Text(
        shop.name,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: shop.imageUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    shop.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: AppColors.primaryGreen),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: AppColors.primaryGreen),
      ),
      expandedHeight: 200,
    );
  }
}
"""

with open(r'c:\\Users\\loli\\localboost\\client\\lib\\screens\\my_card_detail_page.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done. Lines:", content.count('\\n'))
