import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_client/screens/flyer_detail_page.dart';

/// Compact flyer card for use in carousels.
class FlyerCard extends StatelessWidget {
  final Flyer flyer;
  final double width;

  const FlyerCard({super.key, required this.flyer, this.width = 160});

  @override
  Widget build(BuildContext context) {
    final isRecent =
        DateTime.now().difference(flyer.publishedDate).inDays <= 3;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FlyerDetailPage(flyer: flyer)),
      ),
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
