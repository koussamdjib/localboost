import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_merchant/models/loyalty_program.dart';
import 'package:localboost_merchant/screens/loyalty/loyalty_form_screen.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

/// Full-page detail screen for a single loyalty program.
/// Shows aggregate KPIs and a list of enrolled customers.
class LoyaltyDetailScreen extends StatefulWidget {
  final LoyaltyProgram program;

  const LoyaltyDetailScreen({super.key, required this.program});

  @override
  State<LoyaltyDetailScreen> createState() => _LoyaltyDetailScreenState();
}

class _LoyaltyDetailScreenState extends State<LoyaltyDetailScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() => _isLoading = true);
    await context
        .read<EnrollmentProvider>()
        .loadShopEnrollments(widget.program.shopId);
    if (mounted) setState(() => _isLoading = false);
  }

  List<Enrollment> get _programEnrollments {
    return context
        .watch<EnrollmentProvider>()
        .enrollments
        .where((e) => e.loyaltyProgramId == widget.program.id)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final enrollments = _programEnrollments;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          program.title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Modifier',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => LoyaltyFormScreen(program: program)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGreen,
        onRefresh: _loadEnrollments,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildKpiRow(program),
              const SizedBox(height: 20),
              _buildProgressCard(program),
              const SizedBox(height: 20),
              _buildEnrollmentSection(enrollments),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKpiRow(LoyaltyProgram p) {
    return Row(
      children: [
        Expanded(child: _kpi('Inscrits', '${p.enrollmentCount}', Icons.people, AppColors.primaryGreen)),
        const SizedBox(width: 12),
        Expanded(child: _kpi('Actifs', '${p.activeMembers}', Icons.loyalty, AppColors.urgencyOrange)),
        const SizedBox(width: 12),
        Expanded(child: _kpi('Rédemptions', '${p.redemptionCount}', Icons.check_circle_outline, Colors.blue)),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalText)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade600),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildProgressCard(LoyaltyProgram p) {
    final rate = (p.redemptionRate * 100).toStringAsFixed(0);
    final stamps = p.totalStampsGranted;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Vue d\'ensemble',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
                fontSize: 14)),
        const SizedBox(height: 12),
        Row(children: [
          const Icon(Icons.local_activity, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text('Timbres octroyés : ',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
          Text('$stamps',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.bar_chart, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text('Taux de rédemption : ',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
          Text('$rate%',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.star_outline, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text('Timbres requis : ',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
          Text('${p.stampsRequired}',
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        if (p.validityStatus.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.schedule, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 6),
            Text(p.validityStatus,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700)),
          ]),
        ],
        if (p.enrollmentCount > 0) ...[
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p.redemptionRate.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primaryGreen,
              minHeight: 8,
            ),
          ),
        ],
      ]),
    );
  }

  Widget _buildEnrollmentSection(List<Enrollment> enrollments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Clients inscrits (${enrollments.length})',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.charcoalText,
              fontSize: 15),
        ),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(
              child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen)))
        else if (enrollments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.people_outline,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Text('Aucun client inscrit pour l\'instant',
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade500, fontSize: 14)),
              ]),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: enrollments.length,
            itemBuilder: (_, i) => _enrollmentRow(enrollments[i]),
          ),
      ],
    );
  }

  Widget _enrollmentRow(Enrollment e) {
    final progress = widget.program.stampsRequired > 0
        ? (e.stampsCollected / widget.program.stampsRequired).clamp(0.0, 1.0)
        : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.15),
            child: Text(
              (e.customerName?.isNotEmpty == true)
                  ? e.customerName![0].toUpperCase()
                  : '?',
              style: GoogleFonts.poppins(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text((e.customerName?.isNotEmpty == true) ? e.customerName! : 'Client',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.charcoalText)),
              Text(
                  '${e.stampsCollected} / ${widget.program.stampsRequired} timbres',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: Colors.grey.shade600)),
            ]),
          ),
          _statusChip(e),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: e.isRedeemed
                ? Colors.orange
                : AppColors.primaryGreen,
            minHeight: 5,
          ),
        ),
      ]),
    );
  }

  Widget _statusChip(Enrollment e) {
    final Color color;
    final String label;
    if (e.isRedeemed) {
      color = Colors.orange;
      label = 'Récompensé';
    } else if (e.stampsCollected >= widget.program.stampsRequired &&
        widget.program.stampsRequired > 0) {
      color = AppColors.primaryGreen;
      label = 'Complet';
    } else {
      color = Colors.grey.shade400;
      label = 'En cours';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
