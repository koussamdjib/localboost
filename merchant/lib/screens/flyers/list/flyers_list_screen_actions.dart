part of '../flyers_list_screen.dart';

extension _FlyersListScreenActions on _FlyersListScreenState {
  void _createFlyer() {
    final selectedShop = context.read<ShopProvider>().selectedShop;
    if (selectedShop == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez une boutique avant de créer une circulaire'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FlyerFormScreen(),
      ),
    ).then((_) => _loadFlyers());
  }

  void _editFlyer(Flyer flyer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlyerFormScreen(flyer: flyer),
      ),
    ).then((_) => _loadFlyers());
  }

  void _viewFlyer(Flyer flyer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.description_outlined, color: AppColors.primaryGreen, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          flyer.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoalText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (flyer.description?.isNotEmpty == true) ...[
                    Text(
                      flyer.description!,
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (flyer.startDate != null || flyer.endDate != null) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          [
                            if (flyer.startDate != null)
                              'Du ${flyer.startDate!.day}/${flyer.startDate!.month}/${flyer.startDate!.year}',
                            if (flyer.endDate != null)
                              'au ${flyer.endDate!.day}/${flyer.endDate!.month}/${flyer.endDate!.year}',
                          ].join(' '),
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (flyer.fileUrl?.isNotEmpty == true) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          flyer.fileType == FlyerType.pdf ? Icons.picture_as_pdf : Icons.image,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            flyer.fileUrl!,
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accentBlue),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (flyer.status == FlyerStatus.published
                                  ? AppColors.primaryGreen
                                  : Colors.orange)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          flyer.status == FlyerStatus.published ? 'Publié' : 'Brouillon',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: flyer.status == FlyerStatus.published
                                ? AppColors.primaryGreen
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${flyer.viewCount ?? 0} vues · ${flyer.shareCount ?? 0} partages',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _editFlyer(flyer);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text('Modifier', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                        side: const BorderSide(color: AppColors.primaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteFlyer(Flyer flyer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la circulaire'),
        content: Text('Voulez-vous vraiment supprimer "${flyer.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<FlyerProvider>();
      final success = await provider.deleteFlyer(flyer.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Circulaire supprimée'
                  : (provider.error ?? 'Erreur lors de la suppression'),
            ),
          ),
        );
      }
    }
  }
}
