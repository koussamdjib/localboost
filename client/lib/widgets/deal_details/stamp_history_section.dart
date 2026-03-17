import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/stamp_history.dart';
import 'package:localboost_shared/services/stamp_history_service.dart';

class StampHistorySection extends StatefulWidget {
  final List<StampHistory>? history;
  final String? enrollmentId;

  const StampHistorySection({
    super.key,
    this.history,
    this.enrollmentId,
  });

  @override
  State<StampHistorySection> createState() => _StampHistorySectionState();
}

class _StampHistorySectionState extends State<StampHistorySection> {
  bool _isExpanded = false;
  Future<List<StampHistory>>? _historyFuture;
  String? _historyEnrollmentId;

  @override
  void initState() {
    super.initState();
    _syncHistoryFuture();
  }

  @override
  void didUpdateWidget(covariant StampHistorySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enrollmentId != widget.enrollmentId) {
      _syncHistoryFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fallbackHistory = widget.history ?? const <StampHistory>[];
    if (_historyFuture == null && fallbackHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_historyFuture != null) {
      return FutureBuilder<List<StampHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          return _buildSection(
            history: snapshot.data ?? const <StampHistory>[],
            isLoading: snapshot.connectionState == ConnectionState.waiting,
            errorMessage: snapshot.hasError
                ? 'Impossible de charger l\'historique des timbres.'
                : null,
          );
        },
      );
    }

    return _buildSection(history: fallbackHistory);
  }

  void _syncHistoryFuture() {
    final enrollmentId = widget.enrollmentId;
    if (enrollmentId == null || enrollmentId.isEmpty) {
      _historyEnrollmentId = null;
      _historyFuture = null;
      return;
    }

    if (_historyEnrollmentId == enrollmentId && _historyFuture != null) {
      return;
    }

    _historyEnrollmentId = enrollmentId;
    _historyFuture =
        StampHistoryService().fetchStampHistory(enrollmentId: enrollmentId);
  }

  Widget _buildSection({
    required List<StampHistory> history,
    bool isLoading = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Text(
                  'Historique des timbres',
                  style: GoogleFonts.poppins(
                    color: AppColors.charcoalText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLoading ? '...' : '${history.length}',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.charcoalText,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: _buildExpandedContent(
            history: history,
            isLoading: isLoading,
            errorMessage: errorMessage,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent({
    required List<StampHistory> history,
    required bool isLoading,
    String? errorMessage,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 14),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text(
          errorMessage,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      );
    }

    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Text(
          'Aucun timbre collecté pour le moment.',
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: history.map((historyItem) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        historyItem.formattedDate,
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        historyItem.merchantNote,
                        style: GoogleFonts.poppins(
                          color: AppColors.charcoalText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (historyItem.location != null) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 13,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                historyItem.location!,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
