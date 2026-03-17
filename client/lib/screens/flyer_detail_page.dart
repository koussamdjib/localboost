import 'package:flutter/material.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_client/screens/flyer_detail/flyer_detail_app_bar.dart';
import 'package:localboost_client/screens/flyer_detail/flyer_detail_header.dart';
import 'package:localboost_client/screens/flyer_detail/flyer_detail_info_card.dart';
import 'package:localboost_client/screens/flyer_detail/flyer_detail_products_section.dart';

class FlyerDetailPage extends StatelessWidget {
  final Flyer flyer;

  const FlyerDetailPage({super.key, required this.flyer});

  @override
  Widget build(BuildContext context) {
    final hasProducts = flyer.products != null && flyer.products!.isNotEmpty;
    final hasDescription =
        flyer.description != null && flyer.description!.isNotEmpty;
    final hasDates = flyer.startDate != null || flyer.endDate != null;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: CustomScrollView(
        slivers: [
          FlyerDetailAppBar(flyer: flyer),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FlyerDetailHeader(flyer: flyer),
                if (hasDescription || hasDates) ...[
                  const SizedBox(height: 12),
                  FlyerDetailInfoCard(flyer: flyer),
                ],
                if (hasProducts) ...[
                  const SizedBox(height: 12),
                  FlyerDetailProductsSection(products: flyer.products!),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
