"""Add QR button to MyCardDetailPage."""
path = r'client\lib\screens\my_card_detail_page.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Add new imports
old = ("import 'package:localboost_shared/core/constants/app_colors.dart';\r\n"
       "import 'package:localboost_shared/models/shop.dart';\r\n")
new = ("import 'package:localboost_shared/core/constants/app_colors.dart';\r\n"
       "import 'package:localboost_shared/models/shop.dart';\r\n"
       "import 'package:localboost_client/screens/qr_code_screen.dart';\r\n"
       "import 'package:localboost_shared/providers/enrollment_provider.dart';\r\n"
       "import 'package:provider/provider.dart';\r\n")
assert old in text, f'imports not found in {path}'
text = text.replace(old, new, 1)

# Add QR button section before the reward button
old = ('                if (shop.isComplete && !shop.isRedeemed) ...[\r\n'
       '                  const SizedBox(height: 16),\r\n'
       '                  CardDetailRewardButton(shop: shop),\r\n'
       '                ],\r\n'
       '                const SizedBox(height: 32),')
new = ('                if (shop.enrollmentId != null) ...[\r\n'
       '                  const SizedBox(height: 12),\r\n'
       '                  _buildQrButton(context),\r\n'
       '                ],\r\n'
       '                if (shop.isComplete && !shop.isRedeemed) ...[\r\n'
       '                  const SizedBox(height: 16),\r\n'
       '                  CardDetailRewardButton(shop: shop),\r\n'
       '                ],\r\n'
       '                const SizedBox(height: 32),')
assert old in text, f'reward button block not found in {path}'
text = text.replace(old, new, 1)

# Add _buildQrButton method before _buildAppBar
old = '  Widget _buildAppBar(BuildContext context) {'
new = ('  Widget _buildQrButton(BuildContext context) {\r\n'
       '    return Padding(\r\n'
       '      padding: const EdgeInsets.symmetric(horizontal: 16),\r\n'
       '      child: SizedBox(\r\n'
       '        width: double.infinity,\r\n'
       '        child: OutlinedButton.icon(\r\n'
       '          onPressed: () {\r\n'
       '            final enrollmentId = shop.enrollmentId;\r\n'
       '            if (enrollmentId == null) return;\r\n'
       '            final provider = context.read<EnrollmentProvider>();\r\n'
       '            final enrollment = provider.enrollments\r\n'
       '                .where((e) => e.id == enrollmentId)\r\n'
       '                .firstOrNull;\r\n'
       '            if (enrollment == null) return;\r\n'
       '            Navigator.of(context).push(\r\n'
       '              MaterialPageRoute(\r\n'
       '                fullscreenDialog: true,\r\n'
       '                builder: (_) => QRCodeScreen(enrollment: enrollment),\r\n'
       '              ),\r\n'
       '            );\r\n'
       '          },\r\n'
       '          icon: const Icon(Icons.qr_code_2, color: AppColors.primaryGreen),\r\n'
       '          label: Text(\r\n'
       '            \'Montrer mon QR\',\r\n'
       '            style: TextStyle(\r\n'
       '              color: AppColors.primaryGreen,\r\n'
       '              fontWeight: FontWeight.w600,\r\n'
       '            ),\r\n'
       '          ),\r\n'
       '          style: OutlinedButton.styleFrom(\r\n'
       '            side: const BorderSide(color: AppColors.primaryGreen),\r\n'
       '            padding: const EdgeInsets.symmetric(vertical: 14),\r\n'
       '            shape: RoundedRectangleBorder(\r\n'
       '              borderRadius: BorderRadius.circular(14),\r\n'
       '            ),\r\n'
       '          ),\r\n'
       '        ),\r\n'
       '      ),\r\n'
       '    );\r\n'
       '  }\r\n'
       '\r\n'
       '  Widget _buildAppBar(BuildContext context) {')
assert '  Widget _buildAppBar(BuildContext context) {' in text, '_buildAppBar not found'
text = text.replace('  Widget _buildAppBar(BuildContext context) {', new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
