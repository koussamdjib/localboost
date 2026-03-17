"""Remove qr_code_id from accounts/serializers.py."""
path = r'backend\apps\accounts\serializers.py'
with open(path, 'r', newline='') as f:
    text = f.read()

# Remove field declaration
old = '\r\n    qr_code_id = serializers.SerializerMethodField()'
assert old in text, 'qr_code_id field declaration not found'
text = text.replace(old, '', 1)

# Remove from fields list
old = '            "name",\r\n            "phone_number",\r\n            "qr_code_id",\r\n            "created_at",'
new = '            "name",\r\n            "phone_number",\r\n            "created_at",'
assert old in text, 'qr_code_id in fields list not found'
text = text.replace(old, new, 1)

# Remove from read_only_fields
old = '            "created_at",\r\n            "last_login",\r\n            "qr_code_id",\r\n            "total_stamps",'
new = '            "created_at",\r\n            "last_login",\r\n            "total_stamps",'
assert old in text, 'qr_code_id in read_only_fields not found'
text = text.replace(old, new, 1)

# Remove get_qr_code_id method
old = ('\r\n    def get_qr_code_id(self, obj):\r\n'
       '        """\r\n'
       '        Return a unique QR code identifier for the user.\r\n'
       '        Using user ID as the QR code identifier.\r\n'
       '        """\r\n'
       '        return str(obj.id)\r\n')
assert old in text, 'get_qr_code_id method not found'
text = text.replace(old, '\r\n', 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
