import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:localboost_merchant/models/merchant_shop.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/screens/shops/create_shop_screen.dart';
import 'package:localboost_merchant/screens/shops/edit_shop_screen.dart';
import 'package:localboost_merchant/screens/shop/shop_profile_screen.dart';

class MyShopsScreen extends StatefulWidget {
  const MyShopsScreen({super.key});

  @override
  State<MyShopsScreen> createState() => _MyShopsScreenState();
}

class _MyShopsScreenState extends State<MyShopsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ShopProvider>().loadMyShops();
    });
  }

  Future<void> _openCreateShop() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateShopScreen()),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boutique creee avec succes.')),
      );
    }
  }

  Future<void> _openEditShop(MerchantShop shop) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditShopScreen(shop: shop)),
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Boutique mise a jour.')),
      );
    }
  }

  Future<void> _deleteShop(MerchantShop shop) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archiver cette boutique ?'),
          content: Text(
            'La boutique "${shop.name}" sera archivee et retiree de la vitrine publique.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final provider = context.read<ShopProvider>();
    final deleted = await provider.deleteShop(shop.id);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? 'Boutique archivee.'
              : (provider.error ?? 'Impossible d\'archiver cette boutique.'),
        ),
      ),
    );
  }

  Color _statusColor(MerchantShopStatus status) {
    switch (status) {
      case MerchantShopStatus.active:
        return Colors.green;
      case MerchantShopStatus.suspended:
        return Colors.orange;
      case MerchantShopStatus.archived:
        return Colors.grey;
      case MerchantShopStatus.draft:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes boutiques'),
        actions: [
          IconButton(
            onPressed: () => context.read<ShopProvider>().loadMyShops(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateShop,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Nouvelle boutique'),
      ),
      body: Consumer<ShopProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.shops.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.shops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.loadMyShops,
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.shops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 72),
                    const SizedBox(height: 12),
                    const Text(
                      'Aucune boutique pour ce marchand.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _openCreateShop,
                      icon: const Icon(Icons.add),
                      label: const Text('Creer ma premiere boutique'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadMyShops,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
              itemCount: provider.shops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shop = provider.shops[index];
                final isSelected = provider.selectedShop?.id == shop.id;
                final statusColor = _statusColor(shop.status);

                return Card(
                  child: ListTile(
                    onTap: () => provider.selectShop(shop.id),
                    title: Text(shop.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(shop.address),
                        if (shop.category.trim().isNotEmpty)
                          Text('Categorie: ${shop.category}'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                shop.status.label,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Chip(
                                label: Text('Selectionnee'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Voir le profil',
                          onPressed: () {
                            provider.selectShop(shop.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ShopProfileScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.info_outline),
                        ),
                        IconButton(
                          tooltip: 'Modifier',
                          onPressed: () => _openEditShop(shop),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          tooltip: 'Archiver',
                          onPressed: () => _deleteShop(shop),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
