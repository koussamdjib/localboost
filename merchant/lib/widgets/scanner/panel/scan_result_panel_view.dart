part of '../scan_result_panel.dart';

extension _ScanResultPanelView on ScanResultPanel {
  Widget _buildScanResultPanel() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildProgressSection(),
          const SizedBox(height: 12),
          _buildStatusMessage(),
        ],
      ),
    );
  }
}
