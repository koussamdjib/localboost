import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';

/// Filter status for enrollment list
enum EnrollmentFilter {
  all,
  active,
  completed,
  redeemed,
}

/// Filter chips for enrollment list
class EnrollmentFilters extends StatelessWidget {
  final EnrollmentFilter selectedFilter;
  final ValueChanged<EnrollmentFilter> onFilterChanged;
  final int allCount;
  final int activeCount;
  final int completedCount;
  final int redeemedCount;

  const EnrollmentFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
    required this.redeemedCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'Tous',
            count: allCount,
            filter: EnrollmentFilter.all,
            color: AppColors.charcoalText,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Actifs',
            count: activeCount,
            filter: EnrollmentFilter.active,
            color: AppColors.accentBlue,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Complets',
            count: completedCount,
            filter: EnrollmentFilter.completed,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Utilises',
            count: redeemedCount,
            filter: EnrollmentFilter.redeemed,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required EnrollmentFilter filter,
    required Color color,
  }) {
    final isSelected = selectedFilter == filter;
    
    return GestureDetector(
      onTap: () => onFilterChanged(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.charcoalText,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.3) 
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
