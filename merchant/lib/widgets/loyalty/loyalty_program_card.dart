import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_merchant/models/loyalty_program.dart';
import 'package:localboost_merchant/widgets/loyalty/program_status_chip.dart';

part 'card/loyalty_program_card_header.dart';
part 'card/loyalty_program_card_content.dart';
part 'card/loyalty_program_card_stats.dart';

/// Card widget for displaying a loyalty program in the list
class LoyaltyProgramCard extends StatelessWidget {
  final LoyaltyProgram program;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onActivate;
  final VoidCallback? onPause;
  final VoidCallback? onArchive;

  const LoyaltyProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onActivate,
    this.onPause,
    this.onArchive,
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
              _buildStampsBadge(),
              const SizedBox(height: 12),
              _buildDescription(),
              const SizedBox(height: 12),
              _buildStats(),
              const SizedBox(height: 8),
              _buildValidity(),
            ],
          ),
        ),
      ),
    );
  }
}
