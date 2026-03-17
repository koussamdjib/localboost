import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:localboost_client/widgets/deal_details/bottom_actions.dart';
import 'package:localboost_client/widgets/deal_details/deal_header_section.dart';
import 'package:localboost_client/widgets/deal_details/description_section.dart';
import 'package:localboost_client/widgets/deal_details/enrollment_section.dart';
import 'package:localboost_client/widgets/deal_details/location_section.dart';
import 'package:localboost_client/widgets/deal_details/progress_section.dart';
import 'package:localboost_client/widgets/deal_details/remaining_stamps_box.dart';
import 'package:localboost_client/widgets/deal_details/reward_card.dart';
import 'package:localboost_client/widgets/deal_details/shop_image_header.dart';
import 'package:localboost_client/widgets/deal_details/stamp_history_section.dart';
import 'package:localboost_client/widgets/deal_details/terms_section.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/core/utils/share_helper.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/services/api/api_client.dart';

/// Full-screen deal details page
class DealDetailsPage extends StatefulWidget {
  final Shop shop;

  const DealDetailsPage({
    super.key,
    required this.shop,
  });

  @override
  State<DealDetailsPage> createState() => _DealDetailsPageState();
}

class _DealDetailsPageState extends State<DealDetailsPage> {
  bool _requestedEnrollmentLoad = false;

  @override
  void initState() {
    super.initState();
    _trackDealView();
  }

  void _trackDealView() {
    final id = widget.shop.id;
    if (id.startsWith('deal-')) {
      final dealId = id.substring(5);
      ApiClient.instance.post('deals/$dealId/view/').ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShopImageHeader(
                  imageUrl: widget.shop.imageUrl,
                  logoUrl: widget.shop.logoUrl,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DealHeaderSection(
                        shopName: widget.shop.name,
                        dealType: widget.shop.dealType,
                        timeLeft: widget.shop.timeLeft,
                      ),
                      const SizedBox(height: 12),
                      LocationSection(
                        address: widget.shop.location,
                        latitude: widget.shop.latitude,
                        longitude: widget.shop.longitude,
                      ),
                      const SizedBox(height: 20),
                      if (widget.shop.dealType == 'Loyalty') ...[
                        EnrollmentSection(shop: widget.shop),
                        const SizedBox(height: 20),
                      ],
                      if (widget.shop.dealType == 'Loyalty') ...[
                        ProgressSection(
                          totalRequired: widget.shop.totalRequired,
                          currentStamps: widget.shop.stamps,
                        ),
                        const SizedBox(height: 12),
                        RemainingStampsBox(
                          isComplete: widget.shop.isComplete,
                          remainingStamps: widget.shop.remainingStamps,
                        ),
                        const SizedBox(height: 20),
                        _buildLiveHistorySection(),
                      ],
                      RewardCard(
                        rewardIcon: widget.shop.rewardIcon,
                        rewardValue: widget.shop.rewardValue,
                      ),
                      const SizedBox(height: 20),
                      DescriptionSection(
                        dealType: widget.shop.dealType,
                        shopName: widget.shop.name,
                        rewardValue: widget.shop.rewardValue,
                        totalRequired: widget.shop.totalRequired,
                        timeLeft: widget.shop.timeLeft,
                      ),
                      const SizedBox(height: 20),
                      TermsSection(
                        timeLeft: widget.shop.timeLeft,
                        location: widget.shop.location,
                        dealType: widget.shop.dealType,
                        totalRequired: widget.shop.totalRequired,
                      ),
                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomActions(
        latitude: widget.shop.latitude,
        longitude: widget.shop.longitude,
      ),
    );
  }

  Widget _buildLiveHistorySection() {
    return Consumer2<EnrollmentProvider, AuthProvider>(
      builder: (context, enrollmentProvider, authProvider, child) {
        _ensureEnrollmentsLoaded(authProvider, enrollmentProvider);

        final resolvedEnrollmentId = widget.shop.enrollmentId ??
            enrollmentProvider.getEnrollmentFor(widget.shop.id)?.id;
        final hasFallbackHistory = widget.shop.history?.isNotEmpty ?? false;
        if (resolvedEnrollmentId == null && !hasFallbackHistory) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            StampHistorySection(
              enrollmentId: resolvedEnrollmentId,
              history: widget.shop.history,
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _ensureEnrollmentsLoaded(
    AuthProvider authProvider,
    EnrollmentProvider enrollmentProvider,
  ) {
    if (_requestedEnrollmentLoad ||
        authProvider.user == null ||
        widget.shop.enrollmentId != null ||
        enrollmentProvider.isLoading ||
        enrollmentProvider.enrollments.isNotEmpty) {
      return;
    }

    _requestedEnrollmentLoad = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      enrollmentProvider.loadEnrollments(authProvider.user!.id);
    });
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: AppColors.primaryGreen),
          onPressed: () => ShareHelper.shareOffer(widget.shop),
        ),
      ],
    );
  }
}
