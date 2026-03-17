part of '../scan_result_panel.dart';

extension _ScanResultPanelHeader on ScanResultPanel {
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor().withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                enrollment.shopName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoalText,
                ),
              ),
              if (enrollment.loyaltyProgramName != null &&
                  enrollment.loyaltyProgramName!.isNotEmpty) ...
                [
                  const SizedBox(height: 2),
                  Text(
                    enrollment.loyaltyProgramName!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              if (enrollment.customerName != null &&
                  enrollment.customerName!.isNotEmpty) ...
                [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        enrollment.customerName!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ScannerService.getStatusMessage(enrollment),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
