import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_client/screens/deal_details_page.dart';
import 'package:localboost_client/widgets/deal_card_widget.dart';
import 'package:localboost_shared/models/shop.dart';

/// "Deals" tab — list of active deals for this enterprise.
class EnterpriseTabDeals extends StatelessWidget {
  final List<Shop> deals;

  const EnterpriseTabDeals({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Aucun deal disponible',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final shop = deals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DealCardWidget(
            shop: shop,
            onTap: (s) => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DealDetailsPage(shop: s)),
            ),
          ),
        );
      },
    );
  }
}
