import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_merchant/models/loyalty_program.dart';

/// Color-coded status badge for loyalty programs
class ProgramStatusChip extends StatelessWidget {
  final ProgramStatus status;
  final bool compact;

  const ProgramStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(compact ? 4 : 6),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 12 : 14,
            color: config.iconColor,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              status.displayName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: config.textColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(ProgramStatus status) {
    switch (status) {
      case ProgramStatus.draft:
        return _StatusConfig(
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          iconColor: Colors.grey.shade600,
          textColor: Colors.grey.shade700,
          icon: Icons.edit,
        );
      case ProgramStatus.active:
        return _StatusConfig(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade300,
          iconColor: Colors.green.shade700,
          textColor: Colors.green.shade800,
          icon: Icons.check_circle,
        );
      case ProgramStatus.paused:
        return _StatusConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade300,
          iconColor: Colors.orange.shade700,
          textColor: Colors.orange.shade800,
          icon: Icons.pause_circle,
        );
      case ProgramStatus.archived:
        return _StatusConfig(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade300,
          iconColor: Colors.red.shade700,
          textColor: Colors.red.shade800,
          icon: Icons.archive,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.icon,
  });
}
