import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';

/// Dropdown that lets the merchant switch between their shops.
/// Renders nothing when the merchant has only one shop (or none).
class ShopSelectorDropdown extends StatelessWidget {
  const ShopSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ShopProvider>(
      builder: (context, shopProvider, _) {
        final shops = shopProvider.shops;
        if (shops.length <= 1) return const SizedBox.shrink();

        final selectedId = shopProvider.selectedShop?.id;

        return DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedId,
            isDense: true,
            icon: const Icon(Icons.arrow_drop_down, size: 20),
            items: shops.map((shop) {
              return DropdownMenuItem<int>(
                value: shop.id,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    shop.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                context.read<ShopProvider>().selectShop(id);
              }
            },
          ),
        );
      },
    );
  }
}
