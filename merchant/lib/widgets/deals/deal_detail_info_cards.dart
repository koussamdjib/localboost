import 'package:flutter/material.dart';
import 'package:localboost_merchant/models/deal.dart';

/// Description, schedule, reward setup, and terms info cards for a deal.
class DealDetailInfoCards extends StatelessWidget {
  final Deal deal;
  const DealDetailInfoCards({super.key, required this.deal});

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(deal.description.isEmpty
                    ? 'No description provided.'
                    : deal.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Schedule',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Start: ${_formatDate(deal.startDate)}'),
                Text('End: ${_formatDate(deal.endDate)}'),
                Text('Time left: ${deal.timeLeft}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reward setup',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Reward type: ${deal.rewardType.displayName}'),
                Text('Reward value: ${deal.rewardValue}'),
                if (deal.dealType == DealType.loyalty)
                  Text('Stamps required: ${deal.stampsRequired}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Terms and conditions',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(deal.termsAndConditions.isEmpty
                    ? 'No terms provided.'
                    : deal.termsAndConditions),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
