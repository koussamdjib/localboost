part of '../deal_card_widget.dart';

extension _DealCardWidgetBody on DealCardWidget {
  Widget _buildImage() {
    if (deal.imageUrl == null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey.shade400),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        deal.imageUrl!,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 120,
          color: Colors.grey.shade200,
          child: Center(
            child: Icon(Icons.broken_image, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      deal.description,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey.shade700,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
