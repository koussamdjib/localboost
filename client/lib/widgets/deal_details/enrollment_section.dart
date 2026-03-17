import 'package:flutter/material.dart';
import 'package:localboost_client/widgets/deal_details/enrolled_card.dart';
import 'package:localboost_client/widgets/deal_details/redemption_dialog.dart';
import 'package:localboost_client/widgets/deal_details/unenrolled_card.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';

/// Enrollment section wrapper with Consumer2 and state handling
class EnrollmentSection extends StatelessWidget {
  final Shop shop;

  const EnrollmentSection({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnrollmentProvider, AuthProvider>(
      builder: (context, enrollmentProvider, authProvider, child) {
        final isEnrolled = enrollmentProvider.isEnrolledIn(shop.id);
        final enrollment = enrollmentProvider.getEnrollmentFor(shop.id);

        if (isEnrolled && enrollment != null) {
          return EnrolledCard(
            enrollment: enrollment,
            isLoading: enrollmentProvider.isLoading,
            onRedeemReward: () => RedemptionDialog.show(
              context: context,
              shop: shop,
              enrollment: enrollment,
              userId: authProvider.user!.id,
            ),
          );
        } else {
          return UnenrolledCard(
            isLoading: enrollmentProvider.isLoading,
            onEnroll: () => _handleEnrollment(
              context,
              enrollmentProvider,
              authProvider,
            ),
          );
        }
      },
    );
  }

  Future<void> _handleEnrollment(
    BuildContext context,
    EnrollmentProvider enrollmentProvider,
    AuthProvider authProvider,
  ) async {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour vous inscrire.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final parsedShopId = int.tryParse(shop.id);
    if (parsedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Programme invalide: identifiant boutique introuvable.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await enrollmentProvider.enroll(
      userId: authProvider.user!.id,
      shopId: parsedShopId.toString(),
      shopName: shop.name,
      stampsRequired: shop.totalRequired,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enrollmentProvider.error ?? 'Erreur lors de l\'inscription.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await enrollmentProvider.loadEnrollments(authProvider.user!.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Inscrit avec succes!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
