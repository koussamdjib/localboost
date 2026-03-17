part of '../deal_card_widget.dart';

extension _DealCardWidgetHeader on DealCardWidget {
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deal.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  DealStatusChip(status: deal.status),
                  const SizedBox(width: 8),
                  _buildDealTypeBadge(),
                ],
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'activate':
                onActivate?.call();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            if (deal.isDraft && onActivate != null)
              const PopupMenuItem(value: 'activate', child: Text('Activer')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ],
    );
  }

  Widget _buildDealTypeBadge() {
    final config = _getDealTypeConfig();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config['icon'], size: 12, color: config['color']),
          const SizedBox(width: 4),
          Text(
            deal.dealType.displayName,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: config['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDealTypeConfig() {
    switch (deal.dealType) {
      case DealType.flashSale:
        return {'color': AppColors.urgencyOrange, 'icon': Icons.flash_on};
      case DealType.loyalty:
        return {'color': AppColors.primaryGreen, 'icon': Icons.loyalty};
      case DealType.standard:
        return {'color': AppColors.accentBlue, 'icon': Icons.local_offer};
    }
  }
}
