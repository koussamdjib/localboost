import 'package:flutter/material.dart';

/// GPS location card used in create/edit shop forms.
///
/// Displays current lat/lng (or a placeholder), a clear button when a
/// position is set, and a "Obtenir GPS" button that triggers [onGetGps].
class ShopFormGpsCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final VoidCallback onGetGps;
  final VoidCallback onClearGps;

  const ShopFormGpsCard({
    super.key,
    this.latitude,
    this.longitude,
    required this.isLoading,
    required this.onGetGps,
    required this.onClearGps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localisation GPS',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    latitude != null && longitude != null
                        ? 'Lat: ${latitude!.toStringAsFixed(6)}'
                            '\nLng: ${longitude!.toStringAsFixed(6)}'
                        : 'Position non définie',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (latitude != null)
                  IconButton(
                    tooltip: 'Effacer',
                    icon: const Icon(Icons.clear),
                    onPressed: onClearGps,
                  ),
                const SizedBox(width: 4),
                FilledButton.tonalIcon(
                  onPressed: isLoading ? null : onGetGps,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: const Text('Obtenir GPS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
