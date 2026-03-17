import 'package:flutter/material.dart';
import 'package:localboost_merchant/models/deal.dart';

/// Performance snapshot card: stat chips + conversion funnel progress bars.
class DealDetailAnalyticsCard extends StatelessWidget {
  final Deal deal;
  const DealDetailAnalyticsCard({super.key, required this.deal});

  double? _ratio(int numerator, int denominator) {
    if (denominator <= 0) return null;
    return (numerator / denominator).clamp(0.0, 1.0);
  }

  String _formatPercent(double? value) {
    if (value == null) return 'n/a';
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final views = deal.viewCount;
    final enrollments = deal.enrollmentCount;
    final redemptions = deal.redemptionCount;
    final shares = deal.shareCount;

    final enrollmentRate = _ratio(enrollments, views);
    final redemptionRate = _ratio(redemptions, enrollments);
    final shareRate = _ratio(shares, views);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance snapshot',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _StatChip(label: 'Views', value: views.toString()),
                _StatChip(label: 'Enrollments', value: enrollments.toString()),
                _StatChip(label: 'Redemptions', value: redemptions.toString()),
                _StatChip(label: 'Shares', value: shares.toString()),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Conversion funnel',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _FunnelRow(
              label: 'View -> Enrollment',
              ratio: enrollmentRate,
              valueLabel: _formatPercent(enrollmentRate),
              color: Colors.blue,
            ),
            const SizedBox(height: 8),
            _FunnelRow(
              label: 'Enrollment -> Redemption',
              ratio: redemptionRate,
              valueLabel: _formatPercent(redemptionRate),
              color: Colors.green,
            ),
            const SizedBox(height: 8),
            _FunnelRow(
              label: 'View -> Share',
              ratio: shareRate,
              valueLabel: _formatPercent(shareRate),
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$value\n',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            TextSpan(
              text: label,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class _FunnelRow extends StatelessWidget {
  final String label;
  final double? ratio;
  final String valueLabel;
  final Color color;
  const _FunnelRow({
    required this.label,
    required this.ratio,
    required this.valueLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Text(valueLabel,
                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio ?? 0,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6),
          color: color,
          backgroundColor: color.withValues(alpha: 0.18),
        ),
      ],
    );
  }
}
