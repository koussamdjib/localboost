part of '../transaction_history_page.dart';

extension _TransactionHistoryContent on _TransactionHistoryPageState {
  Widget _buildTransactionsBody(String userId) {
    return FutureBuilder<List<Transaction>>(
      future: _getTransactionsFuture(userId),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? const <Transaction>[];
        final filteredTransactions = _filterTransactions(transactions);

        return Column(
          children: [
            _buildFilterSection(),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (snapshot.hasError)
              Expanded(
                child: _buildEmptyState(
                  'Impossible de charger l\'historique depuis le VPS',
                ),
              )
            else if (filteredTransactions.isEmpty)
              Expanded(child: _buildEmptyState('Aucune transaction trouvée'))
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    final showDateHeader = index == 0 ||
                        !_isSameDay(
                          transaction.timestamp,
                          filteredTransactions[index - 1].timestamp,
                        );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader) ...[
                          if (index > 0) const SizedBox(height: 16),
                          _buildDateHeader(transaction.timestamp),
                          const SizedBox(height: 12),
                        ],
                        _buildTransactionCard(transaction),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
