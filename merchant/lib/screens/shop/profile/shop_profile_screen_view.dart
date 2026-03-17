part of '../shop_profile_screen.dart';

extension _ShopProfileScreenView on ShopProfileScreen {
  Widget _buildShopProfileScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma boutique'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final account = context.read<ShopProvider>().merchantAccount;
              if (account == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Aucune boutique selectionnee.')),
                );
                return;
              }

              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => EditBusinessHoursScreen(
                    initialHours: account.businessHours,
                  ),
                ),
              );

              if (!context.mounted) {
                return;
              }

              if (updated == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Horaires mis a jour.')),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<ShopProvider>(
          builder: (context, shopProvider, _) {
            final account = shopProvider.merchantAccount;

            if (account == null) {
              return _buildEmptyState();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.businessName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    account.category.toString().split('.').last,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoSection(
                    icon: Icons.location_on,
                    title: 'Adresse',
                    content: account.address,
                  ),
                  const SizedBox(height: 16),
                  if (account.phone != null)
                    _InfoSection(
                      icon: Icons.phone,
                      title: 'Téléphone',
                      content: account.phone!,
                    ),
                  const SizedBox(height: 16),
                  _InfoSection(
                    icon: Icons.access_time,
                    title: 'Heures d\'ouverture',
                    content: account.businessHours.getOpeningStatus(),
                  ),
                  const SizedBox(height: 16),
                  _VerificationBadge(isVerified: account.isVerified),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun profil de boutique',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
