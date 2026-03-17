part of '../loyalty_list_screen.dart';

extension _LoyaltyListScreenView on _LoyaltyListScreenState {
  Widget _buildLoyaltyListScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmes Fidélité'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Actifs'),
            Tab(text: 'Brouillons'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreate,
            tooltip: 'Créer un programme',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<LoyaltyProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _buildProgramsList(provider.activePrograms, 'actifs'),
                _buildProgramsList(provider.draftPrograms, 'en brouillon'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgramsList(List programs, String emptyLabel) {
    if (programs.isEmpty) {
      return _buildEmptyState('Aucun programme $emptyLabel');
    }

    return RefreshIndicator(
      onRefresh: _loadPrograms,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: programs.length,
        itemBuilder: (context, index) {
          final program = programs[index];
          return LoyaltyProgramCard(
            program: program,
            onTap: () => _navigateToDetail(context, program),
            onEdit: () => _navigateToEdit(program),
            onDelete: () => _confirmDelete(program),
            onActivate: () => _activateProgram(program.id),
            onPause: () => _pauseProgram(program.id),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_giftcard, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToCreate,
            icon: const Icon(Icons.add),
            label: const Text('Créer un programme'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
