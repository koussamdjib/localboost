part of '../flyer_card_widget.dart';

extension _FlyerCardWidgetThumbnail on FlyerCardWidget {
  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: flyer.thumbnailUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                flyer.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      flyer.fileType == FlyerType.pdf ? Icons.picture_as_pdf : Icons.image,
      size: 40,
      color: Colors.grey.shade400,
    );
  }
}
