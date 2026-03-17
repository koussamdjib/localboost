import 'package:flutter/material.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_merchant/widgets/flyers/flyer_status_chip.dart';

part 'card/flyer_card_widget_thumbnail.dart';
part 'card/flyer_card_widget_content.dart';
part 'card/flyer_card_widget_actions.dart';

/// Card widget for merchant flyer list
class FlyerCardWidget extends StatelessWidget {
  final Flyer flyer;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FlyerCardWidget({
    super.key,
    required this.flyer,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              Expanded(child: _buildContent(context)),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }
}
