"""Fix 'widget' references in qr_code_screen_sections.dart.
In an extension on QRCodeScreen (StatelessWidget), use 'enrollment' directly (it's a field on 'this').
"""
path = r'client\lib\screens\qr_code\qr_code_screen_sections.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()

# Replace widget.enrollment.qrToken -> enrollment.qrToken
text = text.replace('widget.enrollment.qrToken', 'enrollment.qrToken')
text = text.replace('widget.enrollment.id', 'enrollment.id')
text = text.replace('widget.enrollment.shopName', 'enrollment.shopName')

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)
print(f'Updated {path}')
