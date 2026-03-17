"""Remove qrCodeId from User model and fix test files."""

# ----- user.dart -----
path = r'shared\lib\models\user.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()

# Remove field declaration
old = '\r\n  // QR Code identifier for stamp collection\r\n  final String qrCodeId; // e.g., "LOCALBOOST-DJIBOUTI-USER-12345"\r\n'
assert old in text, 'qrCodeId field not found'
text = text.replace(old, '\r\n', 1)

# Remove from constructor
old = '    required this.qrCodeId,\r\n'
assert old in text, 'required qrCodeId not found'
text = text.replace(old, '', 1)

# Remove from fromJson
old = "      qrCodeId: firstNonNullString(['qrCodeId', 'qr_code_id', 'id']) ?? '',\r\n"
assert old in text, 'qrCodeId fromJson not found'
text = text.replace(old, '', 1)

# Remove from toJson
old = "      'qrCodeId': qrCodeId,\r\n"
assert old in text, 'qrCodeId toJson not found'
text = text.replace(old, '', 1)

# Remove from copyWith param
old = '    String? qrCodeId,\r\n'
assert old in text, 'qrCodeId copyWith param not found'
text = text.replace(old, '', 1)

# Remove from copyWith body
old = '      qrCodeId: qrCodeId ?? this.qrCodeId,\r\n'
assert old in text, 'qrCodeId copyWith body not found'
text = text.replace(old, '', 1)

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)
print(f'Updated {path}')

# ----- shared test -----
path = r'shared\test\shared_models_smoke_test.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()
old = "        qrCodeId: 'LOCALBOOST-DJIBOUTI-USER-1',\r\n"
if old in text:
    text = text.replace(old, '', 1)
    print('Removed qrCodeId from shared smoke test')
with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)

# ----- merchant tests -----
for p in [
    r'merchant\test\shop_business_hours_flow_test.dart',
    r'merchant\test\merchant_auth_wrapper_test.dart',
]:
    with open(p, 'r', newline='', encoding='utf-8') as f:
        t = f.read()
    for old_line in ["    qrCodeId: 'MERCHANT-QR',\r\n", "    qrCodeId: 'MERCHANT-QR',\n"]:
        if old_line in t:
            t = t.replace(old_line, '', 1)
            print(f'Removed qrCodeId from {p}')
    with open(p, 'w', newline='', encoding='utf-8') as f:
        f.write(t)

# ----- client test -----
p = r'client\test\auth_wrapper_test.dart'
with open(p, 'r', newline='', encoding='utf-8') as f:
    t = f.read()
for old_line in ["    qrCodeId: 'TEST-QR',\r\n", "    qrCodeId: 'TEST-QR',\n"]:
    if old_line in t:
        t = t.replace(old_line, '', 1)
        print(f'Removed qrCodeId from {p}')
with open(p, 'w', newline='', encoding='utf-8') as f:
    f.write(t)

print('All done.')
