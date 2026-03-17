part of '../shop_profile_screen.dart';

class _VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const _VerificationBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 20,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isVerified ? 'Vérifié' : 'En attente de vérification',
            style: TextStyle(
              color:
                  isVerified ? Colors.green.shade900 : Colors.orange.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
