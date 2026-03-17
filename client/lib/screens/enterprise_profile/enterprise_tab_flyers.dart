import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_client/screens/flyer_detail_page.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/flyer.dart';

/// "Prospectus" tab — flyers/circulaires for this enterprise.
class EnterpriseTabFlyers extends StatelessWidget {
  final List<Flyer> flyers;

  const EnterpriseTabFlyers({super.key, required this.flyers});

  @override
  Widget build(BuildContext context) {
    if (flyers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Aucun prospectus disponible',
              style: GoogleFonts.poppins(
                  color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: flyers.length,
      itemBuilder: (context, index) {
        final flyer = flyers[index];
        return _FlyerGridCard(flyer: flyer);
      },
    );
  }
}

class _FlyerGridCard extends StatelessWidget {
  final Flyer flyer;

  const _FlyerGridCard({required this.flyer});

  @override
  Widget build(BuildContext context) {
    final imageUrl = flyer.thumbnailUrl?.isNotEmpty == true
        ? flyer.thumbnailUrl!
        : flyer.fileUrl ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FlyerDetailPage(flyer: flyer)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => _thumbFallback(),
                      )
                    : _thumbFallback(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flyer.title,
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoalText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (flyer.endDate != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Jusqu\'au ${_formatDate(flyer.endDate!)}',
                      style: GoogleFonts.poppins(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(
          flyer.fileType == FlyerType.pdf
              ? Icons.picture_as_pdf
              : Icons.image_outlined,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
