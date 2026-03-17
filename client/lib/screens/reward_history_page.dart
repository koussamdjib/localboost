import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/services/enrollment_service.dart';
import 'package:localboost_client/screens/reward_history/reward_filter_bar.dart';
import 'package:localboost_client/screens/reward_history/reward_request_card.dart';

class RewardHistoryPage extends StatefulWidget {
  const RewardHistoryPage({super.key});

  @override
  State<RewardHistoryPage> createState() => _RewardHistoryPageState();
}

class _RewardHistoryPageState extends State<RewardHistoryPage> {
  String _selectedFilter = 'Tous';
  Future<List<RewardRequest>>? _requestsFuture;

  Future<List<RewardRequest>> _loadRewardRequests() async {
    final provider = context.read<EnrollmentProvider>();
    final requests = await provider.fetchRewardRequests();
    requests.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return requests;
  }

  Future<List<RewardRequest>> _getRequestsFuture() {
    _requestsFuture ??= _loadRewardRequests();
    return _requestsFuture!;
  }

  Future<void> _refresh() async {
    setState(() {
      _requestsFuture = _loadRewardRequests();
    });
    await _requestsFuture;
  }

  List<RewardRequest> _filterRequests(List<RewardRequest> input) {
    switch (_selectedFilter) {
      case 'En attente':
        return input.where((r) => r.status == 'requested').toList();
      case 'Approuvées':
        return input.where((r) => r.status == 'approved').toList();
      case 'Validées':
        return input.where((r) => r.status == 'fulfilled').toList();
      case 'Rejetées':
        return input.where((r) => r.status == 'rejected').toList();
      case 'Tous':
      default:
        return input;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_giftcard, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsBody() {
    return FutureBuilder<List<RewardRequest>>(
      future: _getRequestsFuture(),
      builder: (context, snapshot) {
        final requests = snapshot.data ?? const <RewardRequest>[];
        final filtered = _filterRequests(requests);

        return Column(
          children: [
            RewardFilterBar(
              selectedFilter: _selectedFilter,
              onFilterChanged: (value) =>
                  setState(() => _selectedFilter = value),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryGreen),
                ),
              )
            else if (snapshot.hasError)
              Expanded(
                child: _buildEmptyState(
                  'Impossible de charger l\'historique des recompenses',
                ),
              )
            else if (filtered.isEmpty)
              Expanded(
                child: _buildEmptyState(
                    'Aucune demande de recompense trouvée'),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryGreen,
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        RewardRequestCard(request: filtered[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
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
          'Historique des recompenses',
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
              'Connectez-vous pour voir vos demandes de recompense',
            );
          }
          return _buildRequestsBody();
        },
      ),
    );
  }
}
