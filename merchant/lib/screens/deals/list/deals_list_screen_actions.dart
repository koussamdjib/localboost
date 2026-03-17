part of '../deals_list_screen.dart';

extension _DealsListScreenActions on _DealsListScreenState {
  void _navigateToCreateDeal() {
    final selectedShop = context.read<ShopProvider>().selectedShop;
    if (selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez une boutique avant de créer une offre'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DealFormScreen()),
    ).then((_) => _loadDeals());
  }

  void _navigateToDealDetail(Deal deal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DealDetailScreen(deal: deal)),
    ).then((_) => _loadDeals());
  }

  void _navigateToEditDeal(Deal deal) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DealFormScreen(deal: deal)),
    ).then((_) => _loadDeals());
  }

  Future<void> _activateDeal(String dealId) async {
    final dealProvider = context.read<DealProvider>();
    final success = await dealProvider.activateDeal(dealId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Offre activée' : (dealProvider.error ?? 'Erreur lors de l\'activation'),
          ),
        ),
      );
    }
  }

  void _confirmDelete(Deal deal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'offre'),
        content: Text('Voulez-vous vraiment supprimer "${deal.title}" ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDeal(deal.id);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDeal(String dealId) async {
    final dealProvider = context.read<DealProvider>();
    final success = await dealProvider.deleteDeal(dealId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Offre supprimée' : (dealProvider.error ?? 'Erreur lors de la suppression'),
          ),
        ),
      );
    }
  }
}
