"""Rewrite merchant scanner_service.dart to use UUID token validation instead of parseQrCode/findEnrollment."""
path = r'merchant\lib\services\scanner_service.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Replace parseQrCode with parseEnrollmentToken
old = ("  /// Parse QR code format: LOCALBOOST-DJIBOUTI-USER-{userId}\r\n"
       "  /// Returns the extracted userId or null if invalid format\r\n"
       "  static String? parseQrCode(String qrCode) {\r\n"
       "    if (qrCode.isEmpty) return null;\r\n"
       "    \r\n"
       "    // Support multiple formats:\r\n"
       "    // 1. Full format: LOCALBOOST-DJIBOUTI-USER-12345\r\n"
       "    // 2. Direct userId: 12345\r\n"
       "    if (qrCode.startsWith('LOCALBOOST-DJIBOUTI-USER-')) {\r\n"
       "      return qrCode.replaceFirst('LOCALBOOST-DJIBOUTI-USER-', '');\r\n"
       "    }\r\n"
       "    \r\n"
       "    // If it doesn't match the format, treat the whole code as userId\r\n"
       "    return qrCode;\r\n"
       "  }\r\n"
       "\r\n"
       "  /// Validate QR code format\r\n"
       "  static bool isValidQrCode(String qrCode) {\r\n"
       "    final userId = parseQrCode(qrCode);\r\n"
       "    return userId != null && userId.isNotEmpty;\r\n"
       "  }\r\n"
       "\r\n"
       "  /// Find enrollment for scanned user and shop\r\n"
       "  /// Returns null if user is not enrolled\r\n"
       "  static Enrollment? findEnrollment({\r\n"
       "    required String userId,\r\n"
       "    required String shopId,\r\n"
       "    required EnrollmentProvider enrollmentProvider,\r\n"
       "  }) {\r\n"
       "    try {\r\n"
       "      return enrollmentProvider.enrollments.firstWhere(\r\n"
       "        (e) => e.userId == userId && e.shopId == shopId && !e.isRedeemed,\r\n"
       "      );\r\n"
       "    } catch (e) {\r\n"
       "      return null;\r\n"
       "    }\r\n"
       "  }")
new = ("  /// Parse enrollment QR token (UUID format).\r\n"
       "  /// Returns the token string or null if blank.\r\n"
       "  static String? parseEnrollmentToken(String qrCode) {\r\n"
       "    final trimmed = qrCode.trim();\r\n"
       "    return trimmed.isEmpty ? null : trimmed;\r\n"
       "  }\r\n"
       "\r\n"
       "  /// Validate that the scanned code is a non-empty string (UUID check is server-side).\r\n"
       "  static bool isValidQrCode(String qrCode) {\r\n"
       "    final token = parseEnrollmentToken(qrCode);\r\n"
       "    return token != null && token.isNotEmpty;\r\n"
       "  }")
assert old in text, f'parseQrCode block not found in {path}'
text = text.replace(old, new, 1)

# Remove the unused EnrollmentProvider import (findEnrollment no longer needs it)
old = "import 'package:localboost_shared/providers/enrollment_provider.dart';\r\n"
assert old in text, 'EnrollmentProvider import not found'
text = text.replace(old, '', 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
