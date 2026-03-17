import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Reusable image picker row used in create/edit shop screens.
///
/// Shows a thumbnail preview (memory bytes, network URL, or placeholder),
/// an upload button, an optional filename label, and a clear/undo button
/// when [bytes] is non-null.
///
/// The appearance of the clear button adapts based on [existingUrl]:
/// - With an existing URL → orange undo button ("Annuler")
/// - Without an existing URL → red delete button ("Retirer")
class ShopFormImagePicker extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final String? fileName;

  /// Server-side URL of the already-saved image. Pass empty string for create.
  final String existingUrl;

  final VoidCallback onPick;
  final VoidCallback onClear;

  const ShopFormImagePicker({
    super.key,
    required this.label,
    this.bytes,
    this.fileName,
    this.existingUrl = '',
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasNewFile = bytes != null;
    final hasExistingUrl = existingUrl.isNotEmpty;

    Widget preview;
    if (hasNewFile) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(bytes!, width: 72, height: 72, fit: BoxFit.cover),
      );
    } else if (hasExistingUrl) {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          existingUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      );
    } else {
      preview = Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            preview,
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.upload_outlined, size: 18),
                  label: Text(
                    hasNewFile || hasExistingUrl ? 'Changer' : 'Choisir une image',
                  ),
                ),
                if (fileName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      fileName!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (hasNewFile)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: Icon(
                      hasExistingUrl ? Icons.undo : Icons.delete_outline,
                      size: 16,
                    ),
                    label: Text(hasExistingUrl ? 'Annuler' : 'Retirer'),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          hasExistingUrl ? Colors.orange : Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
