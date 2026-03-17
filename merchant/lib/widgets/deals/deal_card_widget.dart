import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/widgets/deals/deal_status_chip.dart';

part 'card/deal_card_widget_header.dart';
part 'card/deal_card_widget_body.dart';
part 'card/deal_card_widget_metadata.dart';

/// Card widget for displaying a deal in the list
class DealCardWidget extends StatelessWidget {
  final Deal deal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onActivate;

  const DealCardWidget({
    super.key,
    required this.deal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildImage(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildMetadata(),
            ],
          ),
        ),
      ),
    );
  }
}
