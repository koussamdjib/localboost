part of '../enrollment_details_screen.dart';

extension _EnrollmentDetailsLayout on _EnrollmentDetailsScreenState {
  Widget _buildDetailsScaffold(BuildContext context) {
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
          'Détails client',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(height: 16),
                    _buildProgressBar(),
                    const SizedBox(height: 16),
                    _buildStampGrantButton(context),
                    _buildRewardActionButtons(context),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsCards(),
              const SizedBox(height: 16),
              _buildStampHistory(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStampGrantButton(BuildContext context) {
    // Only show when enrollment can accept stamps
    if (_enrollment.isRedeemed) return const SizedBox.shrink();
    if (_enrollment.rewardStatus == RewardRequestStatus.requested) return const SizedBox.shrink();
    if (_enrollment.rewardStatus == RewardRequestStatus.approved) return const SizedBox.shrink();
    if (_enrollment.stampsCollected >= _enrollment.stampsRequired) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGrantingStamp ? null : _grantStamp,
        icon: _isGrantingStamp
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.add_circle_outline, size: 20),
        label: Text(
          _isGrantingStamp ? 'Ajout en cours...' : 'Accorder un timbre',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 420;
          if (wide) {
            return Row(
              children: [
                Expanded(child: _buildEnrollmentDateCard()),
                const SizedBox(width: 12),
                Expanded(child: _buildLastStampCard()),
              ],
            );
          }

          return Column(
            children: [
              _buildEnrollmentDateCard(),
              const SizedBox(height: 12),
              _buildLastStampCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildEnrollmentDateCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildLastStampCard()),
        ],
      ),
    );
  }

  Widget _buildEnrollmentDateCard() {
    return _buildStatCard(
      'Inscrit le',
      DateFormat('dd MMM yyyy', 'fr_FR').format(_enrollment.enrolledAt),
      Icons.calendar_today,
      AppColors.accentBlue,
    );
  }

  Widget _buildLastStampCard() {
    return _buildStatCard(
      'Dernier timbre',
      _enrollment.lastStampAt != null
          ? _getRelativeDate(_enrollment.lastStampAt!)
          : 'Jamais',
      Icons.history,
      AppColors.urgencyOrange,
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoalText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardActionButtons(BuildContext context) {
    if (_enrollment.rewardStatus != RewardRequestStatus.requested) {
      return const SizedBox.shrink();
    }
    if (_enrollment.rewardRequestId == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.urgencyOrange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.urgencyOrange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.card_giftcard, color: AppColors.urgencyOrange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ce client demande sa récompense',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.urgencyOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isActioning ? null : _rejectReward,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isActioning
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                    : Text('Rejeter', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isActioning ? null : _approveReward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isActioning
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Approuver', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
