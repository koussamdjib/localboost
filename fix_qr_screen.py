"""Update client QRCodeScreen and its part files to take an Enrollment param."""
# 1. qr_code_screen.dart
path = r'client\lib\screens\qr_code_screen.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Add enrollment import and change class to take enrollment param
old = ('import \'package:localboost_shared/core/constants/app_colors.dart\';\r\n'
       'import \'package:localboost_shared/providers/auth_provider.dart\';\r\n'
       '\r\n'
       'part \'qr_code/qr_code_screen_view.dart\';\r\n'
       'part \'qr_code/qr_code_screen_sections.dart\';\r\n'
       '\r\n'
       'class QRCodeScreen extends StatelessWidget {\r\n'
       '  const QRCodeScreen({super.key});\r\n'
       '\r\n'
       '  @override\r\n'
       '  Widget build(BuildContext context) {\r\n'
       '    return _buildQrCodeScaffold(context);\r\n'
       '  }\r\n'
       '}')
new = ('import \'package:localboost_shared/core/constants/app_colors.dart\';\r\n'
       'import \'package:localboost_shared/models/enrollment.dart\';\r\n'
       '\r\n'
       'part \'qr_code/qr_code_screen_view.dart\';\r\n'
       'part \'qr_code/qr_code_screen_sections.dart\';\r\n'
       '\r\n'
       'class QRCodeScreen extends StatelessWidget {\r\n'
       '  final Enrollment enrollment;\r\n'
       '\r\n'
       '  const QRCodeScreen({super.key, required this.enrollment});\r\n'
       '\r\n'
       '  @override\r\n'
       '  Widget build(BuildContext context) {\r\n'
       '    return _buildQrCodeScaffold(context);\r\n'
       '  }\r\n'
       '}')
assert old in text, f'QRCodeScreen class not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# 2. qr_code_screen_sections.dart - replace QR source and userId badge
path = r'client\lib\screens\qr_code\qr_code_screen_sections.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Replace Consumer<AuthProvider> with direct enrollment.qrToken
old = ('          child: Consumer<AuthProvider>(\r\n'
       '            builder: (context, authProvider, child) {\r\n'
       '              final qrCodeId = authProvider.user?.qrCodeId ??\r\n'
       '                  \'LOCALBOOST-DJIBOUTI-USER-12345\';\r\n'
       '              return QrImageView(\r\n'
       '                data: qrCodeId,')
new = ('          child: Builder(\r\n'
       '            builder: (context) {\r\n'
       '              final qrData = widget.enrollment.qrToken.isNotEmpty\r\n'
       '                  ? widget.enrollment.qrToken\r\n'
       '                  : widget.enrollment.id;\r\n'
       '              return QrImageView(\r\n'
       '                data: qrData,')
assert old in text, f'Consumer<AuthProvider> block not found in {path}'
text = text.replace(old, new, 1)

# Replace the userId badge with enrollment info badge
old = ('  Widget _buildUserIdBadge() {\r\n'
       '    return Container(\r\n'
       '      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\r\n'
       '      decoration: BoxDecoration(\r\n'
       '        color: AppColors.lightGray,\r\n'
       '        borderRadius: BorderRadius.circular(12),\r\n'
       '      ),\r\n'
       '      child: Text(\r\n'
       '        \'User ID: LB-DJIBOUTI-12345\',\r\n'
       '        style: GoogleFonts.poppins(\r\n'
       '          color: AppColors.charcoalText,\r\n'
       '          fontSize: 14,\r\n'
       '          fontWeight: FontWeight.w500,\r\n'
       '          letterSpacing: 0.5,\r\n'
       '        ),\r\n'
       '      ),\r\n'
       '    );\r\n'
       '  }')
new = ('  Widget _buildUserIdBadge() {\r\n'
       '    return Container(\r\n'
       '      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\r\n'
       '      decoration: BoxDecoration(\r\n'
       '        color: AppColors.lightGray,\r\n'
       '        borderRadius: BorderRadius.circular(12),\r\n'
       '      ),\r\n'
       '      child: Text(\r\n'
       '        widget.enrollment.shopName,\r\n'
       '        style: GoogleFonts.poppins(\r\n'
       '          color: AppColors.charcoalText,\r\n'
       '          fontSize: 14,\r\n'
       '          fontWeight: FontWeight.w500,\r\n'
       '          letterSpacing: 0.5,\r\n'
       '        ),\r\n'
       '      ),\r\n'
       '    );\r\n'
       '  }')
assert old in text, f'_buildUserIdBadge not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# 3. qr_code_screen_view.dart - update title
path = r'client\lib\screens\qr_code\qr_code_screen_view.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

old = "          'Collecter Timbre',"
new = "          'Mon QR Code',"
assert old in text, f'title not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
