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

# Add QR button before the closing SizedBox(height: 32)
old = ("                if (shop.isComplete && !shop.isRedeemed) ...[\\r\\n"
       "                  const SizedBox(height: 16),\\r\\n"
       "                  CardDetailRewardButton(shop: shop),\\r\\n"
       "                ],\\r\\n"
       "                const SizedBox(height: 32),")
# Let me check the exact content first
print("Checking pattern...")
print(repr(text[text.find('shop.isComplete'):text.find('shop.isComplete')+300]))
