import 'package:flutter/material.dart';
import 'package:localboost_shared/models/flyer.dart';

/// Status chip for merchant flyers
class FlyerStatusChip extends StatelessWidget {
  final FlyerStatus status;
  final bool compact;

  const FlyerStatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 14 : 16,
            color: config.textColor,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(FlyerStatus status) {
    switch (status) {
      case FlyerStatus.draft:
        return _StatusConfig(
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
          textColor: Colors.grey.shade700,
          icon: Icons.edit_outlined,
        );
      case FlyerStatus.published:
        return _StatusConfig(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade300,
          textColor: Colors.green.shade800,
          icon: Icons.check_circle_outline,
        );
      case FlyerStatus.paused:
        return _StatusConfig(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade300,
          textColor: Colors.orange.shade800,
          icon: Icons.pause_circle_outline,
        );
      case FlyerStatus.expired:
        return _StatusConfig(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade300,
          textColor: Colors.red.shade800,
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _StatusConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final IconData icon;

  _StatusConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.icon,
  });
}
