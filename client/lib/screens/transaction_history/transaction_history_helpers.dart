part of '../transaction_history_page.dart';

extension _TransactionHistoryHelpers on _TransactionHistoryPageState {
  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    String label;
    if (transactionDate == today) {
      label = 'Aujourd\'hui';
    } else if (transactionDate == yesterday) {
      label = 'Hier';
    } else {
      const months = [
        'janvier',
        'février',
        'mars',
        'avril',
        'mai',
        'juin',
        'juillet',
        'août',
        'septembre',
        'octobre',
        'novembre',
        'décembre',
      ];
      label = '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return Text(
      label,
      style: GoogleFonts.poppins(
        color: AppColors.charcoalText,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Vos activités apparaîtront ici',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  _TransactionIconStyle _getTransactionStyle(TransactionType type) {
    switch (type) {
      case TransactionType.stampCollected:
        return _TransactionIconStyle(
          icon: Icons.add_circle,
          iconColor: AppColors.primaryGreen,
          bgColor: AppColors.primaryGreen.withValues(alpha: 0.1),
        );
      case TransactionType.rewardRedeemed:
        return _TransactionIconStyle(
          icon: Icons.card_giftcard,
          iconColor: AppColors.successGreen,
          bgColor: AppColors.successGreen.withValues(alpha: 0.1),
        );
      case TransactionType.enrolled:
        return _TransactionIconStyle(
          icon: Icons.how_to_reg,
          iconColor: Colors.blue,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        );
      case TransactionType.unenrolled:
        return _TransactionIconStyle(
          icon: Icons.remove_circle_outline,
          iconColor: Colors.grey,
          bgColor: Colors.grey.withValues(alpha: 0.1),
        );
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
