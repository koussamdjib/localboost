"""Update enrollment service actions and add resolveByToken."""
# Fix enrollment_service_actions.dart
path = r'shared\lib\services\enrollment\enrollment_service_actions.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Replace _addStampImpl: remove userId param, add idempotencyKey
old = ('Future<EnrollmentResult> _addStampImpl({\r\n'
       '  required EnrollmentService service,\r\n'
       '  required String enrollmentId,\r\n'
       '  required String userId,\r\n'
       '}) async {\r\n'
       '  try {\r\n'
       '    final response = await service._apiClient.post(\r\n'
       '      \'enrollments/$enrollmentId/stamps/\',\r\n'
       '      data: <String, dynamic>{\r\n'
       '        \'user_id\': userId,\r\n'
       '        \'quantity\': 1,\r\n'
       '      },\r\n'
       '    );')
new = ('Future<EnrollmentResult> _addStampImpl({\r\n'
       '  required EnrollmentService service,\r\n'
       '  required String enrollmentId,\r\n'
       '  required String idempotencyKey,\r\n'
       '}) async {\r\n'
       '  try {\r\n'
       '    final response = await service._apiClient.post(\r\n'
       '      \'enrollments/$enrollmentId/stamps/\',\r\n'
       '      data: <String, dynamic>{\r\n'
       '        \'idempotency_key\': idempotencyKey,\r\n'
       '        \'quantity\': 1,\r\n'
       '      },\r\n'
       '    );')
assert old in text, f'_addStampImpl signature not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# Append _resolveByTokenImpl at the end of the file
with open(path, 'r', newline='') as f:
    text = f.read()

resolve_fn = (
    '\r\n'
    'Future<EnrollmentResult> _resolveByTokenImpl({\r\n'
    '  required EnrollmentService service,\r\n'
    '  required String qrToken,\r\n'
    '}) async {\r\n'
    '  try {\r\n'
    '    final response = await service._apiClient.post(\r\n'
    '      \'enrollments/scan/\',\r\n'
    '      data: <String, dynamic>{\'qr_token\': qrToken},\r\n'
    '    );\r\n'
    '\r\n'
    '    final enrollment = service.parseEnrollment(response.data);\r\n'
    '    if (enrollment == null) {\r\n'
    '      return EnrollmentResult(\r\n'
    '        success: false,\r\n'
    '        error: \'QR code invalide ou inscription introuvable.\',\r\n'
    '      );\r\n'
    '    }\r\n'
    '\r\n'
    '    return EnrollmentResult(success: true, enrollment: enrollment);\r\n'
    '  } catch (error) {\r\n'
    '    return EnrollmentResult(\r\n'
    '      success: false,\r\n'
    '      error: service.toReadableApiError(error),\r\n'
    '    );\r\n'
    '  }\r\n'
    '}\r\n'
)

text = text.rstrip() + resolve_fn
with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Added _resolveByTokenImpl to {path}')
