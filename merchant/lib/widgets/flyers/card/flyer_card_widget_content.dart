part of '../flyer_card_widget.dart';

extension _FlyerCardWidgetContent on FlyerCardWidget {
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                flyer.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (flyer.description != null)
          Text(
            flyer.description!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 8),
        if (flyer.status != null)
          FlyerStatusChip(status: flyer.status!, compact: true),
        const SizedBox(height: 4),
        _buildMetadata(),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          flyer.validUntil,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        if (flyer.viewCount != null) ...[
          const SizedBox(width: 12),
          Icon(Icons.visibility, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            '${flyer.viewCount}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}
