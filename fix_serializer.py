"""Edit enrollments/serializers.py to add qr_token field."""
path = r'backend\apps\enrollments\serializers.py'
with open(path, 'r', newline='') as f:
    text = f.read()

# Add qr_token to the fields list after "id"
old = '\t\t\t"id",\r\n\t\t\t"user_id",'
new = '\t\t\t"id",\r\n\t\t\t"qr_token",\r\n\t\t\t"user_id",'
assert old in text, 'Pattern not found in fields list'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
