"""Update enrollment_provider_rewards.dart: addStamp uses idempotencyKey."""
path = r'shared\lib\providers\enrollment\enrollment_provider_rewards.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Change addStamp signature and call
old = ('  // Add a stamp (called when merchant scans QR)\r\n'
       '  Future<bool> addStamp(String enrollmentId, String userId) async {\r\n'
       '    try {\r\n'
       '      final result = await _enrollmentService.addStamp(\r\n'
       '        enrollmentId: enrollmentId,\r\n'
       '        userId: userId,\r\n'
       '      );')
new = ('  // Add a stamp (called when merchant scans QR)\r\n'
       '  Future<bool> addStamp(String enrollmentId, String idempotencyKey) async {\r\n'
       '    try {\r\n'
       '      final result = await _enrollmentService.addStamp(\r\n'
       '        enrollmentId: enrollmentId,\r\n'
       '        idempotencyKey: idempotencyKey,\r\n'
       '      );')
assert old in text, f'addStamp signature not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
