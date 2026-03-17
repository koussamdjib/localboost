import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop_discovery_shop.dart';

/// "Informations" tab — shop description, contact info, map.
class EnterpriseTabInfo extends StatelessWidget {
  final ShopDiscoveryShop shop;

  const EnterpriseTabInfo({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        if (shop.description.isNotEmpty) ...[
          _section('À propos'),
          const SizedBox(height: 8),
          _card(
            child: Text(
              shop.description,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _section('Coordonnées'),
        const SizedBox(height: 8),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (shop.address.isNotEmpty)
                _infoRow(Icons.location_on_outlined, shop.address),
              if (shop.phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 10),
                _infoRow(Icons.phone_outlined, shop.phoneNumber),
              ],
              if (shop.category.isNotEmpty) ...[
                const SizedBox(height: 10),
                _infoRow(Icons.category_outlined, shop.category),
              ],
            ],
          ),
        ),
        if (shop.latitude != null && shop.longitude != null) ...[
          const SizedBox(height: 16),
          _section('Localisation'),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(shop.latitude!, shop.longitude!),
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.localboost.client',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            shop.latitude!, shop.longitude!),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: AppColors.primaryGreen,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _section(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
          fontWeight: FontWeight.w700,
          color: AppColors.charcoalText,
          fontSize: 14),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.charcoalText),
          ),
        ),
      ],
    );
  }
}
