"""Remove unused 'provider' import from qr_code_screen.dart."""
path = r'client\lib\screens\qr_code_screen.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

old = "import 'package:provider/provider.dart';\r\n"
assert old in text, 'provider import not found'
text = text.replace(old, '', 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
