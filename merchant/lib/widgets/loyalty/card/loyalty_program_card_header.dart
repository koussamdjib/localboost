part of '../loyalty_program_card.dart';

extension _LoyaltyProgramCardHeader on LoyaltyProgramCard {
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoalText,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              ProgramStatusChip(status: program.status),
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
              case 'pause':
                onPause?.call();
                break;
              case 'archive':
                onArchive?.call();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Modifier')),
            if (program.isDraft && onActivate != null)
              const PopupMenuItem(value: 'activate', child: Text('Activer')),
            if (program.isActive && onPause != null)
              const PopupMenuItem(
                  value: 'pause', child: Text('Mettre en pause')),
            if (program.isPaused && onActivate != null)
              const PopupMenuItem(value: 'activate', child: Text('Reprendre')),
            if (program.canEdit && onArchive != null)
              const PopupMenuItem(value: 'archive', child: Text('Archiver')),
            const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),
      ],
    );
  }
}
