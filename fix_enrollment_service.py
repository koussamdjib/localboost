"""Update enrollment_service.dart: addStamp signature + resolveByToken method."""
path = r'shared\lib\services\enrollment_service.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Change addStamp method signature: userId -> idempotencyKey
old = ('  // Add a stamp to an enrollment (called when merchant scans QR)\r\n'
       '  Future<EnrollmentResult> addStamp({\r\n'
       '    required String enrollmentId,\r\n'
       '    required String userId,\r\n'
       '  }) =>\r\n'
       '      _addStampImpl(service: this, enrollmentId: enrollmentId, userId: userId);')
new = ('  // Add a stamp to an enrollment (called when merchant scans QR)\r\n'
       '  Future<EnrollmentResult> addStamp({\r\n'
       '    required String enrollmentId,\r\n'
       '    required String idempotencyKey,\r\n'
       '  }) =>\r\n'
       '      _addStampImpl(service: this, enrollmentId: enrollmentId, idempotencyKey: idempotencyKey);\r\n'
       '\r\n'
       '  // Resolve a QR token to an enrollment (merchant scanner)\r\n'
       '  Future<EnrollmentResult> resolveByToken(String qrToken) =>\r\n'
       '      _resolveByTokenImpl(service: this, qrToken: qrToken);')
assert old in text, f'addStamp method not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
