part of '../loyalty_form_screen.dart';

extension _LoyaltyFormScreenActions on _LoyaltyFormScreenState {
  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically = constraints.maxWidth < 380;
        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () => _saveProgram(ProgramStatus.draft),
                child: const Text('Sauvegarder comme brouillon'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _saveProgram(ProgramStatus.active),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activer'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _saveProgram(ProgramStatus.draft),
                child: const Text('Sauvegarder comme brouillon'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _saveProgram(ProgramStatus.active),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activer'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProgram(ProgramStatus status) async {
    if (!_formKey.currentState!.validate()) return;

    final stamps = int.tryParse(_stampsController.text);
    if (stamps == null || stamps < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le nombre de timbres doit être au moins 1'),
        ),
      );
      return;
    }

    final shopProvider = context.read<ShopProvider>();
    final loyaltyProvider = context.read<LoyaltyProvider>();
    if (shopProvider.merchantAccount == null) return;

    final program = LoyaltyProgram(
      id: widget.program?.id ??
          'loyalty-${DateTime.now().millisecondsSinceEpoch}',
      shopId: shopProvider.merchantAccount!.shopId,
      title: _titleController.text,
      description: _descriptionController.text,
      stampsRequired: stamps,
      rewardDescription: _rewardController.text,
      termsAndConditions: '',
      validFrom: null,
      validUntil: null,
      status: status,
      maxEnrollments: null,
    );

    final success = widget.program == null
        ? await loyaltyProvider.createProgram(program)
        : await loyaltyProvider.updateProgram(program.id, program);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.program == null
                  ? 'Programme créé'
                  : 'Programme mis à jour',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la sauvegarde')),
        );
      }
    }
  }
}
