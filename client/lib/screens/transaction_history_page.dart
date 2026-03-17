import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/transaction.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/services/transaction_history_service.dart';

part 'transaction_history/transaction_history_filters.dart';
part 'transaction_history/transaction_history_content.dart';
part 'transaction_history/transaction_history_card.dart';
part 'transaction_history/transaction_history_data.dart';
part 'transaction_history/transaction_history_helpers.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  final TransactionHistoryService _transactionHistoryService =
      TransactionHistoryService();

  String _selectedFilter = 'Tous';
  String _selectedPeriod = 'Tout';
  Future<List<Transaction>>? _transactionsFuture;
  String? _transactionsUserId;

  void _updateSelectedFilter(String value) {
    setState(() {
      _selectedFilter = value;
    });
  }

  void _updateSelectedPeriod(String value) {
    setState(() {
      _selectedPeriod = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historique',
          style: GoogleFonts.poppins(
            color: AppColors.charcoalText,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.user == null) {
            return _buildEmptyState(
                'Connectez-vous pour voir votre historique');
          }

          return _buildTransactionsBody(authProvider.user!.id);
        },
      ),
    );
  }
}
