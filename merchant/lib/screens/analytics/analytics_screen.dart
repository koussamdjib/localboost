import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/providers/loyalty_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_client_row.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_deal_card.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_kpi_grid.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_loyalty_card.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_section_widgets.dart';
import 'package:localboost_merchant/widgets/analytics/analytics_today_card.dart';

/// Analytics screen — shows performance metrics for deals and loyalty programs.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isRefreshing = false;
  int _periodIndex = 2; // 0 = this week, 1 = this month, 2 = all time

  static const _periodLabels = ['Semaine', 'Mois', 'Tout'];

  DateTime? get _periodStart {
    final now = DateTime.now();
    if (_periodIndex == 0) {
      // Start of current week (Monday)
      return now.subtract(Duration(days: now.weekday - 1));
    }
    if (_periodIndex == 1) {
      return DateTime(now.year, now.month, 1);
    }
    return null; // all time
  }

  bool _inPeriod(DateTime? date) {
    if (date == null || _periodStart == null) return true;
    return date.isAfter(_periodStart!);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final shopProvider = context.read<ShopProvider>();
    final shopId = shopProvider.merchantAccount?.shopId;
    if (shopId == null) return;

    setState(() => _isRefreshing = true);
    await Future.wait([
      context.read<DealProvider>().loadDeals(shopId),
      context.read<LoyaltyProvider>().loadPrograms(shopId),
      context.read<EnrollmentProvider>().loadShopEnrollments(shopId),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final shopName = context.watch<ShopProvider>().selectedShop?.name ?? '';
    final allDeals = context.watch<DealProvider>().deals;
    final allPrograms = context.watch<LoyaltyProvider>().programs;

    // Apply period filter
    final deals = _periodStart == null
        ? allDeals
        : allDeals.where((d) => _inPeriod(d.startDate)).toList();
    final programs = _periodStart == null
        ? allPrograms
        : allPrograms.where((p) => _inPeriod(p.createdAt)).toList();

    // Aggregate KPIs from loyalty programs
    final totalClients = programs.fold(0, (s, p) => s + p.enrollmentCount);
    final totalStamps = programs.fold(0, (s, p) => s + p.totalStampsGranted);
    final totalRewards = programs.fold(0, (s, p) => s + p.redemptionCount);
    final activeMembers = programs.fold(0, (s, p) => s + p.activeMembers);

    // Aggregate KPIs from deals
    final totalDealViews = deals.fold(0, (s, d) => s + d.viewCount);
    final totalDealParticipants = deals.fold(0, (s, d) => s + d.enrollmentCount);

    // Top clients from enrollment provider
    final allEnrollments = context.watch<EnrollmentProvider>().enrollments;
    final topClients = [...allEnrollments]
      ..sort((a, b) => b.stampsCollected.compareTo(a.stampsCollected));
    final displayClients = topClients.take(10).toList();

    // Today's activity metrics
    final today = DateTime.now();
    final todayStamps = allEnrollments
        .where((e) =>
            e.lastStampAt != null &&
            e.lastStampAt!.year == today.year &&
            e.lastStampAt!.month == today.month &&
            e.lastStampAt!.day == today.day)
        .fold(0, (sum, e) => sum + e.stampsCollected);
    final todayEnrollments = allEnrollments
        .where((e) =>
            e.enrolledAt.year == today.year &&
            e.enrolledAt.month == today.month &&
            e.enrolledAt.day == today.day)
        .length;
    final pendingRewards = allEnrollments
        .where((e) => e.rewardStatus == RewardRequestStatus.requested)
        .length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytiques',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
              ),
            ),
            if (shopName.isNotEmpty)
              Text(
                shopName,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: AppColors.charcoalText),
            onPressed: _isRefreshing ? null : _loadData,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Today's Activity ───────────────────────────────────────
                AnalyticsTodayCard(
                  stampsToday: todayStamps,
                  enrollmentsToday: todayEnrollments,
                  pendingRewards: pendingRewards,
                ),
                const SizedBox(height: 16),
                // ── Period selector ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SegmentedButton<int>(
                    segments: List.generate(
                      _periodLabels.length,
                      (i) => ButtonSegment<int>(
                        value: i,
                        label: Text(
                          _periodLabels[i],
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ),
                    ),
                    selected: {_periodIndex},
                    onSelectionChanged: (s) => setState(() => _periodIndex = s.first),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.primaryGreen;
                        }
                        return Colors.white;
                      }),
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return AppColors.charcoalText;
                      }),
                    ),
                  ),
                ),
                // ── Overview KPI grid ──────────────────────────────────────
                const AnalyticsSectionHeader(
                  icon: Icons.bar_chart,
                  label: 'Vue d\'ensemble',
                  color: AppColors.charcoalText,
                ),
                const SizedBox(height: 12),
                AnalyticsKpiGrid(
                  totalClients: totalClients,
                  totalStamps: totalStamps,
                  totalRewards: totalRewards,
                  activeMembers: activeMembers,
                  totalDealViews: totalDealViews,
                  totalDealParticipants: totalDealParticipants,
                ),
                const SizedBox(height: 24),

                // ── Loyalty programs ───────────────────────────────────────
                const AnalyticsSectionHeader(
                  icon: Icons.loyalty,
                  label: 'Programmes fidélité',
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),
                if (programs.isEmpty)
                  const AnalyticsEmptyCard(message: 'Aucun programme pour cette boutique.')
                else
                  ...programs.map((p) => AnalyticsLoyaltyCard(program: p)),
                const SizedBox(height: 24),

                // ── Deals ──────────────────────────────────────────────────
                const AnalyticsSectionHeader(
                  icon: Icons.local_offer,
                  label: 'Promotions',
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                if (deals.isEmpty)
                  const AnalyticsEmptyCard(message: 'Aucune promotion pour cette boutique.')
                else
                  ...deals.map((deal) => AnalyticsDealCard(deal: deal)),
                const SizedBox(height: 24),

                // ── Top clients ────────────────────────────────────────────
                const AnalyticsSectionHeader(
                  icon: Icons.people_alt,
                  label: 'Top Clients',
                  color: AppColors.accentBlue,
                ),
                const SizedBox(height: 12),
                if (displayClients.isEmpty)
                  const AnalyticsEmptyCard(message: 'Aucun client inscrit pour le moment.')
                else
                  ...displayClients.asMap().entries.map(
                    (entry) => AnalyticsClientRow(rank: entry.key + 1, enrollment: entry.value),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}