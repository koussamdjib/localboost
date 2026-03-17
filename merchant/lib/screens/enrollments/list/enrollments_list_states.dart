part of '../enrollments_list_screen.dart';

extension _EnrollmentsListStates on _EnrollmentsListScreenState {
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun client trouvé',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMerchantAccount() {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: const SafeArea(
        child: Center(child: Text('Compte marchand non configure')),
      ),
    );
  }

  void _navigateToDetails(Enrollment enrollment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnrollmentDetailsScreen(enrollment: enrollment),
      ),
    ).then((_) => _loadEnrollments());
  }

  Future<void> _handleMerchantRewardAction(Enrollment enrollment) async {
    final requestId = enrollment.rewardRequestId;
    if (requestId == null) return;

    final isRequested =
        enrollment.rewardStatus == RewardRequestStatus.requested;
    final isApproved = enrollment.rewardStatus == RewardRequestStatus.approved;

    if (!isRequested && !isApproved) return;

    if (isRequested) {
      // Show approve/reject choice dialog.
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Demande de récompense'),
            content: Text(
              'Le client ${enrollment.customerName ?? enrollment.customerEmail ?? enrollment.userId} a demandé sa récompense.\n\nQue souhaitez-vous faire?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'cancel'),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, 'reject'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Rejeter'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, 'approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Approuver'),
              ),
            ],
          );
        },
      );

      if (choice == null || choice == 'cancel' || !mounted) return;

      final enrollmentProvider = context.read<EnrollmentProvider>();

      if (choice == 'approve') {
        final result =
            await enrollmentProvider.approveRewardRequest(requestId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.success
              ? 'Demande approuvée.'
              : (enrollmentProvider.error ?? 'Erreur lors de l\'approbation.')),
        ));
      } else if (choice == 'reject') {
        final result =
            await enrollmentProvider.rejectRewardRequest(requestId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.success
              ? 'Demande rejetée.'
              : (enrollmentProvider.error ?? 'Erreur lors du rejet.')),
        ));
      }

      _loadEnrollments();
      return;
    }

    // isApproved → confirm fulfill.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remettre la récompense'),
          content: Text(
            'Confirmer la remise de la récompense au client ${enrollment.customerName ?? enrollment.customerEmail ?? enrollment.userId}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final enrollmentProvider = context.read<EnrollmentProvider>();
    final result = await enrollmentProvider.fulfillRewardRequest(requestId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result.success
          ? 'Récompense remise avec succès.'
          : (enrollmentProvider.error ?? 'Échec de la remise.')),
    ));

    if (result.success) {
      _loadEnrollments();
    }
  }
}
