"""Remove global QR FAB from main_screen.dart."""
path = r'client\lib\screens\main_screen.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Remove QRCodeScreen import
old = "import 'package:localboost_client/screens/qr_code_screen.dart';\r\n"
assert old in text, 'qr_code_screen import not found'
text = text.replace(old, '', 1)

# Remove _onCollectPressed method
old = ('  void _onCollectPressed() {\r\n'
       '    // Open QR Code Modal\r\n'
       '    Navigator.of(context).push(\r\n'
       '      MaterialPageRoute(\r\n'
       '        fullscreenDialog: true,\r\n'
       '        builder: (context) => const QRCodeScreen(),\r\n'
       '      ),\r\n'
       '    );\r\n'
       '  }\r\n'
       '\r\n')
assert old in text, '_onCollectPressed not found'
text = text.replace(old, '', 1)

# Remove FAB props from Scaffold
old = ('      floatingActionButton: CollectButton(onPressed: _onCollectPressed),\r\n'
       '      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,\r\n')
assert old in text, 'FAB scaffold props not found'
text = text.replace(old, '', 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
