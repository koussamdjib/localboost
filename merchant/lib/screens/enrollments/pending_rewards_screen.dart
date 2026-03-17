import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/screens/enrollments/enrollment_details_screen.dart';
import 'package:localboost_merchant/widgets/enrollments/pending_reward_card.dart';

/// Screen showing all pending reward requests for the merchant's shop.
class PendingRewardsScreen extends StatefulWidget {
  const PendingRewardsScreen({super.key});

  @override
  State<PendingRewardsScreen> createState() => _PendingRewardsScreenState();
}

class _PendingRewardsScreenState extends State<PendingRewardsScreen> {
  bool _isLoading = false;

  Future<void> _refresh() async {
    final shopProvider = context.read<ShopProvider>();
    final shopId = shopProvider.merchantAccount?.shopId;
    if (shopId == null) return;
    setState(() => _isLoading = true);
    await context.read<EnrollmentProvider>().loadShopEnrollments(shopId);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _approve(Enrollment enrollment) async {
    final requestId = enrollment.rewardRequestId;
    if (requestId == null) return;
    final result =
        await context.read<EnrollmentProvider>().approveRewardRequest(requestId);
    if (!mounted) return;
    if (result.success) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Récompense approuvée !'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            context.read<EnrollmentProvider>().error ?? "Erreur d'approbation"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _reject(Enrollment enrollment) async {
    final requestId = enrollment.rewardRequestId;
    if (requestId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la demande ?'),
        content: const Text('Le client devra soumettre une nouvelle demande.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await context
        .read<EnrollmentProvider>()
        .rejectRewardRequest(requestId);
    if (!mounted) return;
    if (result.success) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Demande rejetée.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _fulfill(Enrollment enrollment) async {
    final requestId = enrollment.rewardRequestId;
    if (requestId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marquer comme accordée ?'),
        content: const Text(
            'La récompense sera marquée comme remise au client.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = await context
        .read<EnrollmentProvider>()
        .fulfillRewardRequest(requestId);
    if (!mounted) return;
    if (result.success) {
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Récompense accordée !'),
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enrollments = context.watch<EnrollmentProvider>().enrollments;
    final pending = enrollments
        .where((e) =>
            e.rewardStatus == RewardRequestStatus.requested ||
            e.rewardStatus == RewardRequestStatus.approved)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Récompenses en attente',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppColors.charcoalText,
            fontSize: 18,
          ),
        ),
        actions: [
          if (pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pending.length}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.charcoalText),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: pending.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 72,
                                color: AppColors.primaryGreen
                                    .withValues(alpha: 0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune récompense en attente',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.charcoalText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toutes les demandes ont été traitées.',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: pending.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return PendingRewardCard(
                          enrollment: pending[index],
                          onApprove: pending[index].rewardStatus ==
                                  RewardRequestStatus.requested
                              ? () => _approve(pending[index])
                              : null,
                          onReject: () => _reject(pending[index]),
                          onFulfill: pending[index].rewardStatus ==
                                  RewardRequestStatus.approved
                              ? () => _fulfill(pending[index])
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EnrollmentDetailsScreen(
                                  enrollment: pending[index]),
                            ),
                          ).then((_) => _refresh()),
                        );
                      },
                    ),
            ),
    );
  }
}
