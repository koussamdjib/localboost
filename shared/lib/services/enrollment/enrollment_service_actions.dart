part of '../enrollment_service.dart';

Future<EnrollmentResult> _enrollImpl({
  required EnrollmentService service,
  required String userId,
  required String shopId,
  required String shopName,
  required int stampsRequired,
  String? loyaltyProgramId,
}) async {
  try {
    final body = <String, dynamic>{};
    if (loyaltyProgramId != null && loyaltyProgramId.isNotEmpty) {
      body['loyalty_program_id'] = loyaltyProgramId;
    } else {
      body['shop_id'] = shopId;
    }

    final response = await service._apiClient.post(
      'enrollments/',
      data: body,
    );

    final enrollment = service.parseEnrollment(response.data);
    if (enrollment == null) {
      return EnrollmentResult(
        success: false,
        error: 'Réponse enrollment invalide depuis le serveur.',
      );
    }

    return EnrollmentResult(
      success: true,
      enrollment: enrollment,
      message: response.statusCode == 201
          ? 'Inscription réussie'
          : 'Inscription déjà active',
    );
  } catch (error) {
    return EnrollmentResult(
      success: false,
      error: service.toReadableApiError(error),
    );
  }
}

Future<EnrollmentResult> _addStampImpl({
  required EnrollmentService service,
  required String enrollmentId,
  required String idempotencyKey,
}) async {
  try {
    final response = await service._apiClient.post(
      'enrollments/$enrollmentId/stamps/',
      data: <String, dynamic>{
        'idempotency_key': idempotencyKey,
        'quantity': 1,
      },
    );

    final enrollment = service.parseEnrollment(response.data);
    if (enrollment == null) {
      return EnrollmentResult(
        success: false,
        error: 'Réponse enrollment invalide après ajout de timbre.',
      );
    }

    return EnrollmentResult(
      success: true,
      enrollment: enrollment,
      message: 'Timbre ajouté avec succès',
    );
  } catch (error) {
    return EnrollmentResult(
      success: false,
      error: service.toReadableApiError(error),
    );
  }
}
Future<EnrollmentResult> _resolveByTokenImpl({
  required EnrollmentService service,
  required String qrToken,
}) async {
  try {
    final response = await service._apiClient.post(
      'enrollments/scan/',
      data: <String, dynamic>{'qr_token': qrToken},
    );

    final enrollment = service.parseEnrollment(response.data);
    if (enrollment == null) {
      return EnrollmentResult(
        success: false,
        error: 'QR code invalide ou inscription introuvable.',
      );
    }

    return EnrollmentResult(success: true, enrollment: enrollment);
  } catch (error) {
    return EnrollmentResult(
      success: false,
      error: service.toReadableApiError(error),
    );
  }
}
