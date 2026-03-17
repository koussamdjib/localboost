"""Add resolveByToken to EnrollmentProvider via account actions part."""
path = r'shared\lib\providers\enrollment\enrollment_provider_account_actions.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()

# Append resolveByToken method before closing brace of extension
# Find the last `}` of the extension
# We'll just append before the final closing brace

# The text ends with the last method. Let's append the method at the end.
resolve_method = (
    "\r\n"
    "  // Resolve a QR token to an enrollment (merchant scanner)\r\n"
    "  Future<EnrollmentResult> resolveByToken(String qrToken) async {\r\n"
    "    try {\r\n"
    "      return await _enrollmentService.resolveByToken(qrToken);\r\n"
    "    } catch (e) {\r\n"
    "      return EnrollmentResult(success: false, error: 'Erreur: $e');\r\n"
    "    }\r\n"
    "  }\r\n"
)

# Insert before last `}`
last_brace = text.rfind('\r\n}')
assert last_brace != -1, 'closing brace not found'
text = text[:last_brace] + resolve_method + text[last_brace:]

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)
print(f'Updated {path}')
