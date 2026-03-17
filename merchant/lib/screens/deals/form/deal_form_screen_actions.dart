part of '../deal_form_screen.dart';

extension _DealFormScreenActions on _DealFormScreenState {
  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 380;
        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => _saveDeal(DealStatus.draft),
                child: const Text('Sauvegarder comme brouillon'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _saveDeal(DealStatus.active),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Publier'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _saveDeal(DealStatus.draft),
                child: const Text('Sauvegarder comme brouillon'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _saveDeal(DealStatus.active),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Publier'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDeal(DealStatus status) async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début'),
        ),
      );
      return;
    }

    final shopProvider = context.read<ShopProvider>();
    final dealProvider = context.read<DealProvider>();
    final selectedShop = shopProvider.selectedShop;
    if (selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectionnez une boutique avant de continuer')),
      );
      return;
    }

    final stampsRequired = _selectedDealType == DealType.loyalty
        ? int.tryParse(_stampsController.text.trim())
        : 0;
    if (_selectedDealType == DealType.loyalty && (stampsRequired == null || stampsRequired < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nombre de timbres doit etre un entier positif')),
      );
      return;
    }

    final maxEnrollments = _hasMaxEnrollments
        ? int.tryParse(_maxEnrollmentsController.text.trim())
        : null;
    if (_hasMaxEnrollments && (maxEnrollments == null || maxEnrollments < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nombre maximal doit etre un entier positif')),
      );
      return;
    }

    final resolvedShopId = (widget.deal?.shopId.isNotEmpty ?? false)
        ? widget.deal!.shopId
        : selectedShop.id.toString();

    final deal = Deal(
      id: widget.deal?.id ?? '',
      shopId: resolvedShopId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dealType: _selectedDealType,
      stampsRequired: stampsRequired ?? 0,
      rewardValue: _rewardValueController.text.trim(),
      rewardType: _selectedRewardType,
      termsAndConditions: _termsController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      status: status,
      maxEnrollments: maxEnrollments,
    );

    final success = widget.deal == null
        ? await dealProvider.createDeal(deal)
        : await dealProvider.updateDeal(widget.deal!.id, deal);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.deal == null ? 'Offre créée' : 'Offre mise à jour'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(dealProvider.error ?? 'Erreur lors de la sauvegarde'),
          ),
        );
      }
    }
  }
}
