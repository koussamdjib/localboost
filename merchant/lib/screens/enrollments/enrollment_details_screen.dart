import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/models/stamp_history.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/services/stamp_history_service.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

part 'details/enrollment_details_screen_layout.dart';
part 'details/enrollment_details_screen_history.dart';
part 'details/enrollment_details_screen_status.dart';

/// Screen displaying detailed enrollment information
class EnrollmentDetailsScreen extends StatefulWidget {
  final Enrollment enrollment;

  const EnrollmentDetailsScreen({
    super.key,
    required this.enrollment,
  });

  @override
  State<EnrollmentDetailsScreen> createState() => _EnrollmentDetailsScreenState();
}

class _EnrollmentDetailsScreenState extends State<EnrollmentDetailsScreen> {
  late Enrollment _enrollment;
  late Future<List<StampHistory>> _historyFuture;
  bool _isGrantingStamp = false;
  bool _isActioning = false;

  @override
  void initState() {
    super.initState();
    _enrollment = widget.enrollment;
    _historyFuture = StampHistoryService().fetchStampHistory(enrollmentId: _enrollment.id);
  }

  Future<void> _grantStamp() async {
    if (_isGrantingStamp) return;
    setState(() => _isGrantingStamp = true);

    final enrollmentProvider = context.read<EnrollmentProvider>();
    final shopProvider = context.read<ShopProvider>();
    final shopId = shopProvider.merchantAccount?.shopId ?? '';

    final success = await enrollmentProvider.addStamp(
      _enrollment.id,
      _enrollment.userId,
    );

    if (!mounted) return;

    if (success) {
      // Refresh enrollment data
      await enrollmentProvider.loadShopEnrollments(shopId);
      final updated = enrollmentProvider.enrollments.where((e) => e.id == _enrollment.id);
      if (updated.isNotEmpty && mounted) {
        setState(() {
          _enrollment = updated.first;
          _historyFuture = StampHistoryService().fetchStampHistory(enrollmentId: _enrollment.id);
          _isGrantingStamp = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Timbre accordé! ${_enrollment.stampsCollected}/${_enrollment.stampsRequired}'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      } else {
        setState(() => _isGrantingStamp = false);
      }
    } else {
      setState(() => _isGrantingStamp = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(enrollmentProvider.error ?? 'Erreur lors de l\'ajout du timbre'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _refreshEnrollment() async {
    final shopProvider = context.read<ShopProvider>();
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final shopId = shopProvider.merchantAccount?.shopId ?? '';
    await enrollmentProvider.loadShopEnrollments(shopId);
    final updated = enrollmentProvider.enrollments.where((e) => e.id == _enrollment.id);
    if (updated.isNotEmpty && mounted) {
      setState(() {
        _enrollment = updated.first;
        _historyFuture = StampHistoryService().fetchStampHistory(enrollmentId: _enrollment.id);
      });
    }
  }

  Future<void> _approveReward() async {
    final requestId = _enrollment.rewardRequestId;
    if (requestId == null || _isActioning) return;
    setState(() => _isActioning = true);
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final result = await enrollmentProvider.approveRewardRequest(requestId);
    if (!mounted) return;
    if (result.success) {
      await _refreshEnrollment();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Récompense approuvée !'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(enrollmentProvider.error ?? "Erreur lors de l'approbation"),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
    if (mounted) setState(() => _isActioning = false);
  }

  Future<void> _rejectReward() async {
    final requestId = _enrollment.rewardRequestId;
    if (requestId == null || _isActioning) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter la demande ?'),
        content: const Text('Le client devra faire une nouvelle demande.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _isActioning = true);
    final enrollmentProvider = context.read<EnrollmentProvider>();
    final result = await enrollmentProvider.rejectRewardRequest(requestId);
    if (!mounted) return;
    if (result.success) {
      await _refreshEnrollment();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Demande rejetée.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(enrollmentProvider.error ?? 'Erreur lors du rejet'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
    if (mounted) setState(() => _isActioning = false);
  }

  @override
  Widget build(BuildContext context) {
    return _buildDetailsScaffold(context);
  }
}

