part of '../loyalty_program_card.dart';

extension _LoyaltyProgramCardStats on LoyaltyProgramCard {
  Widget _buildStats() {
    return Row(
      children: [
        _buildStatItem(Icons.people, '${program.activeMembers} actifs'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.person_add, '${program.enrollmentCount} inscrits'),
        const SizedBox(width: 12),
        _buildStatItem(Icons.redeem, '${program.redemptionCount} récompenses'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(text,
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
