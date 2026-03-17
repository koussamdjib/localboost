import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';

/// Compact flyer card for use in carousels.
class FlyerCard extends StatelessWidget {
  final Flyer flyer;
  final double width;

  const FlyerCard({super.key, required this.flyer, this.width = 160});

  void _openViewer(BuildContext context) {
    final imageUrl = flyer.fileUrl ?? flyer.thumbnailUrl ?? '';
    if (imageUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FlyerImageViewer(flyer: flyer, imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecent =
        DateTime.now().difference(flyer.publishedDate).inDays <= 3;

    return GestureDetector(
      onTap: () => _openViewer(context),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumb(),
            _buildInfo(isRecent),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb() {
    final imageUrl =
        flyer.thumbnailUrl?.isNotEmpty == true ? flyer.thumbnailUrl! : flyer.fileUrl ?? '';

    return Container(
      height: 110,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey.shade100,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => _thumbFallback(),
              )
            : _thumbFallback(),
      ),
    );
  }

  Widget _thumbFallback() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            flyer.fileType == FlyerType.pdf
                ? Icons.picture_as_pdf
                : Icons.image_outlined,
            size: 36,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(bool isRecent) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flyer.storeName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              flyer.title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoalText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                if (isRecent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.urgencyOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Nouveau',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.urgencyOrange,
                      ),
                    ),
                  )
                else
                  Text(
                    flyer.validUntil,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen image viewer for flyers (InteractiveViewer with zoom).
class _FlyerImageViewer extends StatelessWidget {
  final Flyer flyer;
  final String imageUrl;

  const _FlyerImageViewer({required this.flyer, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              flyer.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              flyer.storeName,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            },
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
            ),
          ),
        ),
      ),
    );
  }
}
