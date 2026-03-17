import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/shop.dart';

/// Front face of a loyalty card — shows stamp progress, shop name, and reward.
class LoyaltyCardFront extends StatelessWidget {
  final Shop shop;

  const LoyaltyCardFront({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final progress = shop.totalRequired > 0
        ? (shop.stamps / shop.totalRequired).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: shop.isRedeemed
              ? [Colors.grey.shade500, Colors.grey.shade700]
              : shop.isComplete
                  ? [AppColors.successGreen, const Color(0xFF1B6B3A)]
                  : [AppColors.primaryGreen, AppColors.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (shop.isRedeemed ? Colors.grey : AppColors.primaryGreen)
                .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          const Positioned(
            top: -20,
            right: -20,
            child: _DecorativeCircle(size: 100, opacity: 0.08),
          ),
          const Positioned(
            bottom: -30,
            left: -15,
            child: _DecorativeCircle(size: 130, opacity: 0.06),
          ),
          // Card content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 18),
                _buildStampGrid(),
                const SizedBox(height: 14),
                _buildProgressBar(progress),
                const SizedBox(height: 12),
                _buildRewardRow(),
                const Spacer(),
                _buildFlipHint(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildLogo(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                shop.name,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Carte de fidélité',
                style: GoogleFonts.poppins(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: shop.logoUrl.isNotEmpty
            ? Image.network(
                shop.logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _logoFallback(),
              )
            : _logoFallback(),
      ),
    );
  }

  Widget _logoFallback() {
    return Center(
      child: Text(
        shop.name.isNotEmpty ? shop.name[0].toUpperCase() : '?',
        style: GoogleFonts.poppins(
          color: AppColors.primaryGreen,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (shop.isRedeemed) {
      return _badge('Utilisé', Colors.white.withValues(alpha: 0.3));
    }
    if (shop.isComplete) {
      return _badge('🎉 Prêt', Colors.amber.shade300.withValues(alpha: 0.9));
    }
    return const SizedBox.shrink();
  }

  Widget _badge(String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStampGrid() {
    const maxVisible = 10;
    final total = math.min(shop.totalRequired, maxVisible);
    final collected = math.min(shop.stamps, total);

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: List.generate(total, (i) {
        final filled = i < collected;
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: filled ? 0.0 : 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 17,
            color: filled ? AppColors.primaryGreen : Colors.white.withValues(alpha: 0.6),
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${shop.stamps} / ${shop.totalRequired} timbres',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: GoogleFonts.poppins(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardRow() {
    return Row(
      children: [
        Text(
          shop.rewardIcon,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            shop.rewardValue,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFlipHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.flip, size: 13, color: Colors.white.withValues(alpha: 0.55)),
        const SizedBox(width: 4),
        Text(
          'Appuyer pour voir le QR',
          style: GoogleFonts.poppins(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
