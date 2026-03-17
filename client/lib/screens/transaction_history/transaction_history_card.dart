part of '../transaction_history_page.dart';

extension _TransactionHistoryCard on _TransactionHistoryPageState {
  Widget _buildTransactionCard(Transaction transaction) {
    final style = _getTransactionStyle(transaction.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: style.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(style.icon, color: style.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: _buildTransactionDetails(transaction)),
          const SizedBox(width: 8),
          Text(
            transaction.formattedDate,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails(Transaction transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.shopName,
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          transaction.description,
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
        if (transaction.merchantNote != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.note_outlined, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  transaction.merchantNote!,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (transaction.location != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  transaction.location!,
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TransactionIconStyle {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const _TransactionIconStyle({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}
