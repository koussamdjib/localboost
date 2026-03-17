part of '../transaction_history_page.dart';

extension _TransactionHistoryData on _TransactionHistoryPageState {
  Future<List<Transaction>> _getTransactionsFuture(String userId) {
    if (_transactionsFuture == null || _transactionsUserId != userId) {
      _transactionsUserId = userId;
      _transactionsFuture = _transactionHistoryService.fetchCustomerTransactions();
    }
    return _transactionsFuture!;
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    var filtered = transactions;

    switch (_selectedFilter) {
      case 'Timbres':
        filtered = filtered
            .where((t) => t.type == TransactionType.stampCollected)
            .toList();
        break;
      case 'Récompenses':
        filtered = filtered
            .where((t) => t.type == TransactionType.rewardRedeemed)
            .toList();
        break;
      case 'Inscriptions':
        filtered = filtered
            .where(
              (t) =>
                  t.type == TransactionType.enrolled ||
                  t.type == TransactionType.unenrolled,
            )
            .toList();
        break;
      default:
        break;
    }

    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Aujourd\'hui':
        final today = DateTime(now.year, now.month, now.day);
        filtered = filtered.where((t) {
          final d =
              DateTime(t.timestamp.year, t.timestamp.month, t.timestamp.day);
          return d == today;
        }).toList();
        break;
      case 'Cette semaine':
        final weekAgo = now.subtract(const Duration(days: 7));
        filtered = filtered.where((t) => t.timestamp.isAfter(weekAgo)).toList();
        break;
      case 'Ce mois':
        final monthAgo = now.subtract(const Duration(days: 30));
        filtered =
            filtered.where((t) => t.timestamp.isAfter(monthAgo)).toList();
        break;
      default:
        break;
    }

    return filtered;
  }
}
