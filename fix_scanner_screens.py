"""Update merchant scanner files to use resolveByToken API."""
import re

# ---------- 1. merchant_scanner_screen.dart ----------
# Already updated in previous run. Skip.
print("merchant_scanner_screen.dart already updated.")

# ---------- 2. merchant_scanner_barcode_handler.dart ----------
path = r'merchant\lib\screens\scanner\merchant_scanner\merchant_scanner_barcode_handler.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()

# Replace the entire _handleBarcode method content
old = ("      // Parse QR code\r\n"
       "      final userId = ScannerService.parseQrCode(code);\r\n"
       "      if (userId == null || !ScannerService.isValidQrCode(code)) {\r\n"
       "        _showError('QR code invalide');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "\r\n"
       "      // Find enrollment\r\n"
       "      var enrollment = ScannerService.findEnrollment(\r\n"
       "        userId: userId,\r\n"
       "        shopId: widget.shopId,\r\n"
       "        enrollmentProvider: enrollmentProvider,\r\n"
       "      );\r\n"
       "\r\n"
       "      if (enrollment == null) {\r\n"
       "        await enrollmentProvider.loadShopEnrollments(widget.shopId);\r\n"
       "        enrollment = ScannerService.findEnrollment(\r\n"
       "          userId: userId,\r\n"
       "          shopId: widget.shopId,\r\n"
       "          enrollmentProvider: enrollmentProvider,\r\n"
       "        );\r\n"
       "      }\r\n"
       "\r\n"
       "      if (enrollment == null) {\r\n"
       "        _showError('Client non inscrit \u00e0 ce programme');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      // Show result panel\r\n"
       "      _setStateSafe(() {\r\n"
       "        _scannedEnrollment = enrollment;\r\n"
       "        _scannedUserId = userId;\r\n"
       "        _isProcessing = false;\r\n"
       "      });")
new = ("      // Validate token is non-empty\r\n"
       "      final qrToken = ScannerService.parseEnrollmentToken(code);\r\n"
       "      if (qrToken == null || !ScannerService.isValidQrCode(code)) {\r\n"
       "        _showError('QR code invalide');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      // Resolve token via API\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      final result = await enrollmentProvider.resolveByToken(qrToken);\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      if (!result.success || result.enrollment == null) {\r\n"
       "        _showError(result.error ?? 'QR code non reconnu');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      // Show result panel\r\n"
       "      _setStateSafe(() {\r\n"
       "        _scannedEnrollment = result.enrollment;\r\n"
       "        _isProcessing = false;\r\n"
       "      });")
assert old in text, f'_handleBarcode body not found in {path}'
text = text.replace(old, new, 1)

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)
print(f'Updated {path}')

# ---------- 3. merchant_scanner_actions.dart ----------
path = r'merchant\lib\screens\scanner\merchant_scanner\merchant_scanner_actions.dart'
with open(path, 'r', newline='', encoding='utf-8') as f:
    text = f.read()

# _refreshScannedEnrollment: remove loadShopEnrollments, use resolveByToken
old = ("  Future<void> _refreshScannedEnrollment() async {\r\n"
       "    final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "    await enrollmentProvider.loadShopEnrollments(widget.shopId);\r\n"
       "\r\n"
       "    final updated = enrollmentProvider.enrollments.where(\r\n"
       "      (e) => e.id == _scannedEnrollment?.id,\r\n"
       "    );\r\n"
       "\r\n"
       "    if (!mounted) return;\r\n"
       "\r\n"
       "    if (updated.isNotEmpty) {\r\n"
       "      _setStateSafe(() => _scannedEnrollment = updated.first);\r\n"
       "    } else {\r\n"
       "      _resetScanner();\r\n"
       "    }\r\n"
       "  }")
new = ("  Future<void> _refreshScannedEnrollment() async {\r\n"
       "    final token = _scannedEnrollment?.qrToken;\r\n"
       "    if (token == null || token.isEmpty) {\r\n"
       "      _resetScanner();\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "    final result = await enrollmentProvider.resolveByToken(token);\r\n"
       "\r\n"
       "    if (!mounted) return;\r\n"
       "\r\n"
       "    if (result.success && result.enrollment != null) {\r\n"
       "      _setStateSafe(() => _scannedEnrollment = result.enrollment);\r\n"
       "    } else {\r\n"
       "      _resetScanner();\r\n"
       "    }\r\n"
       "  }")
assert old in text, '_refreshScannedEnrollment not found'
text = text.replace(old, new, 1)

# _handleAddStamp: remove _scannedUserId guard and update addStamp call
old = ("  Future<void> _handleAddStamp() async {\r\n"
       "    if (_scannedEnrollment == null || _scannedUserId == null) return;\r\n"
       "\r\n"
       "    // Validate\r\n"
       "    final error = ScannerService.validateStampEligibility(_scannedEnrollment!);\r\n"
       "    if (error != null) {\r\n"
       "      _showError(error);\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    _setStateSafe(() => _isProcessing = true);\r\n"
       "\r\n"
       "    try {\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      final success = await enrollmentProvider.addStamp(\r\n"
       "        _scannedEnrollment!.id,\r\n"
       "        _scannedUserId!,\r\n"
       "      );")
new = ("  Future<void> _handleAddStamp() async {\r\n"
       "    if (_scannedEnrollment == null) return;\r\n"
       "\r\n"
       "    // Validate\r\n"
       "    final error = ScannerService.validateStampEligibility(_scannedEnrollment!);\r\n"
       "    if (error != null) {\r\n"
       "      _showError(error);\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    _setStateSafe(() => _isProcessing = true);\r\n"
       "\r\n"
       "    try {\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      // Use enrollment id + timestamp as idempotency key for this stamp\r\n"
       "      final idempotencyKey = '${_scannedEnrollment!.id}-${DateTime.now().millisecondsSinceEpoch}';\r\n"
       "      final success = await enrollmentProvider.addStamp(\r\n"
       "        _scannedEnrollment!.id,\r\n"
       "        idempotencyKey,\r\n"
       "      );")
assert old in text, '_handleAddStamp signature not found'
text = text.replace(old, new, 1)

# Remove _scannedUserId from _handleApproveReward guard
old = "  Future<void> _handleApproveReward() async {\r\n    if (_scannedEnrollment == null || _scannedUserId == null) return;"
new = "  Future<void> _handleApproveReward() async {\r\n    if (_scannedEnrollment == null) return;"
if old in text:
    text = text.replace(old, new, 1)
    print("Fixed _handleApproveReward guard")

# Remove _scannedUserId from _handleFulfillReward guard
old = "  Future<void> _handleFulfillReward() async {\r\n    if (_scannedEnrollment == null || _scannedUserId == null) return;"
new = "  Future<void> _handleFulfillReward() async {\r\n    if (_scannedEnrollment == null) return;"
if old in text:
    text = text.replace(old, new, 1)
    print("Fixed _handleFulfillReward guard")

with open(path, 'w', newline='', encoding='utf-8') as f:
    f.write(text)
print(f'Updated {path}')


# Remove EnrollmentProvider import (no longer needed at screen level for loading)
# Actually we still need it for addStamp via provider, keep it

# Remove _scannedUserId field
old = "  bool _isProcessing = false;\r\n  String? _lastScannedCode;\r\n  Enrollment? _scannedEnrollment;\r\n  String? _scannedUserId;\r\n"
new = "  bool _isProcessing = false;\r\n  String? _lastScannedCode;\r\n  Enrollment? _scannedEnrollment;\r\n"
assert old in text, '_scannedUserId field not found'
text = text.replace(old, new, 1)

# Remove loadShopEnrollments from initState
old = ("  @override\r\n"
       "  void initState() {\r\n"
       "    super.initState();\r\n"
       "    WidgetsBinding.instance.addPostFrameCallback((_) {\r\n"
       "      if (!mounted) {\r\n"
       "        return;\r\n"
       "      }\r\n"
       "      context.read<EnrollmentProvider>().loadShopEnrollments(widget.shopId);\r\n"
       "    });\r\n"
       "  }")
new = ("  @override\r\n"
       "  void initState() {\r\n"
       "    super.initState();\r\n"
       "  }")
assert old in text, 'initState with loadShopEnrollments not found'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# ---------- 2. merchant_scanner_barcode_handler.dart ----------
path = r'merchant\lib\screens\scanner\merchant_scanner\merchant_scanner_barcode_handler.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# Replace the entire _handleBarcode method content
old = ("  Future<void> _handleBarcode(BarcodeCapture capture) async {\r\n"
       "    if (_isProcessing || _scannedEnrollment != null) return;\r\n"
       "\r\n"
       "    final List<Barcode> barcodes = capture.barcodes;\r\n"
       "    if (barcodes.isEmpty) return;\r\n"
       "\r\n"
       "    final String? code = barcodes.first.rawValue;\r\n"
       "    if (code == null || code == _lastScannedCode) return;\r\n"
       "\r\n"
       "    _setStateSafe(() {\r\n"
       "      _isProcessing = true;\r\n"
       "      _lastScannedCode = code;\r\n"
       "    });\r\n"
       "\r\n"
       "    try {\r\n"
       "      // Parse QR code\r\n"
       "      final userId = ScannerService.parseQrCode(code);\r\n"
       "      if (userId == null || !ScannerService.isValidQrCode(code)) {\r\n"
       "        _showError('QR code invalide');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "\r\n"
       "      // Find enrollment\r\n"
       "      var enrollment = ScannerService.findEnrollment(\r\n"
       "        userId: userId,\r\n"
       "        shopId: widget.shopId,\r\n"
       "        enrollmentProvider: enrollmentProvider,\r\n"
       "      );\r\n"
       "\r\n"
       "      if (enrollment == null) {\r\n"
       "        await enrollmentProvider.loadShopEnrollments(widget.shopId);\r\n"
       "        enrollment = ScannerService.findEnrollment(\r\n"
       "          userId: userId,\r\n"
       "          shopId: widget.shopId,\r\n"
       "          enrollmentProvider: enrollmentProvider,\r\n"
       "        );\r\n"
       "      }\r\n"
       "\r\n"
       "      if (enrollment == null) {\r\n"
       "        _showError('Client non inscrit à ce programme');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      // Show result panel\r\n"
       "      _setStateSafe(() {\r\n"
       "        _scannedEnrollment = enrollment;\r\n"
       "        _scannedUserId = userId;\r\n"
       "        _isProcessing = false;\r\n"
       "      });\r\n"
       "    } catch (e) {\r\n"
       "      _showError('Erreur: ${e.toString()}');\r\n"
       "    } finally {\r\n"
       "      if (_scannedEnrollment == null) {\r\n"
       "        _setStateSafe(() {\r\n"
       "          _isProcessing = false;\r\n"
       "          _lastScannedCode = null;\r\n"
       "        });\r\n"
       "      }\r\n"
       "    }\r\n"
       "  }")
new = ("  Future<void> _handleBarcode(BarcodeCapture capture) async {\r\n"
       "    if (_isProcessing || _scannedEnrollment != null) return;\r\n"
       "\r\n"
       "    final List<Barcode> barcodes = capture.barcodes;\r\n"
       "    if (barcodes.isEmpty) return;\r\n"
       "\r\n"
       "    final String? code = barcodes.first.rawValue;\r\n"
       "    if (code == null || code == _lastScannedCode) return;\r\n"
       "\r\n"
       "    _setStateSafe(() {\r\n"
       "      _isProcessing = true;\r\n"
       "      _lastScannedCode = code;\r\n"
       "    });\r\n"
       "\r\n"
       "    try {\r\n"
       "      // Validate token is non-empty\r\n"
       "      final qrToken = ScannerService.parseEnrollmentToken(code);\r\n"
       "      if (qrToken == null || !ScannerService.isValidQrCode(code)) {\r\n"
       "        _showError('QR code invalide');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      // Resolve token via API\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      final result = await enrollmentProvider.resolveByToken(qrToken);\r\n"
       "\r\n"
       "      if (!mounted) return;\r\n"
       "\r\n"
       "      if (!result.success || result.enrollment == null) {\r\n"
       "        _showError(result.error ?? 'QR code non reconnu');\r\n"
       "        return;\r\n"
       "      }\r\n"
       "\r\n"
       "      // Show result panel\r\n"
       "      _setStateSafe(() {\r\n"
       "        _scannedEnrollment = result.enrollment;\r\n"
       "        _isProcessing = false;\r\n"
       "      });\r\n"
       "    } catch (e) {\r\n"
       "      _showError('Erreur: ${e.toString()}');\r\n"
       "    } finally {\r\n"
       "      if (_scannedEnrollment == null) {\r\n"
       "        _setStateSafe(() {\r\n"
       "          _isProcessing = false;\r\n"
       "          _lastScannedCode = null;\r\n"
       "        });\r\n"
       "      }\r\n"
       "    }\r\n"
       "  }")
assert old in text, '_handleBarcode body not found'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')

# ---------- 3. merchant_scanner_actions.dart ----------
path = r'merchant\lib\screens\scanner\merchant_scanner\merchant_scanner_actions.dart'
with open(path, 'r', newline='') as f:
    text = f.read()

# _refreshScannedEnrollment: remove loadShopEnrollments, use resolveByToken
old = ("  Future<void> _refreshScannedEnrollment() async {\r\n"
       "    final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "    await enrollmentProvider.loadShopEnrollments(widget.shopId);\r\n"
       "\r\n"
       "    final updated = enrollmentProvider.enrollments.where(\r\n"
       "      (e) => e.id == _scannedEnrollment?.id,\r\n"
       "    );\r\n"
       "\r\n"
       "    if (!mounted) return;\r\n"
       "\r\n"
       "    if (updated.isNotEmpty) {\r\n"
       "      _setStateSafe(() => _scannedEnrollment = updated.first);\r\n"
       "    } else {\r\n"
       "      _resetScanner();\r\n"
       "    }\r\n"
       "  }")
new = ("  Future<void> _refreshScannedEnrollment() async {\r\n"
       "    final token = _scannedEnrollment?.qrToken;\r\n"
       "    if (token == null || token.isEmpty) {\r\n"
       "      _resetScanner();\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "    final result = await enrollmentProvider.resolveByToken(token);\r\n"
       "\r\n"
       "    if (!mounted) return;\r\n"
       "\r\n"
       "    if (result.success && result.enrollment != null) {\r\n"
       "      _setStateSafe(() => _scannedEnrollment = result.enrollment);\r\n"
       "    } else {\r\n"
       "      _resetScanner();\r\n"
       "    }\r\n"
       "  }")
assert old in text, '_refreshScannedEnrollment not found'
text = text.replace(old, new, 1)

# _handleAddStamp: remove _scannedUserId guard and update addStamp call
old = ("  Future<void> _handleAddStamp() async {\r\n"
       "    if (_scannedEnrollment == null || _scannedUserId == null) return;\r\n"
       "\r\n"
       "    // Validate\r\n"
       "    final error = ScannerService.validateStampEligibility(_scannedEnrollment!);\r\n"
       "    if (error != null) {\r\n"
       "      _showError(error);\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    _setStateSafe(() => _isProcessing = true);\r\n"
       "\r\n"
       "    try {\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      final success = await enrollmentProvider.addStamp(\r\n"
       "        _scannedEnrollment!.id,\r\n"
       "        _scannedUserId!,\r\n"
       "      );")
new = ("  Future<void> _handleAddStamp() async {\r\n"
       "    if (_scannedEnrollment == null) return;\r\n"
       "\r\n"
       "    // Validate\r\n"
       "    final error = ScannerService.validateStampEligibility(_scannedEnrollment!);\r\n"
       "    if (error != null) {\r\n"
       "      _showError(error);\r\n"
       "      return;\r\n"
       "    }\r\n"
       "\r\n"
       "    _setStateSafe(() => _isProcessing = true);\r\n"
       "\r\n"
       "    try {\r\n"
       "      final enrollmentProvider = context.read<EnrollmentProvider>();\r\n"
       "      // Use enrollment id + qrToken as idempotency key for this stamp action\r\n"
       "      final idempotencyKey = '${_scannedEnrollment!.id}-${DateTime.now().millisecondsSinceEpoch}';\r\n"
       "      final success = await enrollmentProvider.addStamp(\r\n"
       "        _scannedEnrollment!.id,\r\n"
       "        idempotencyKey,\r\n"
       "      );")
assert old in text, '_handleAddStamp signature not found'
text = text.replace(old, new, 1)

# Also fix the _handleApproveReward guard: remove _scannedUserId check
old = "  Future<void> _handleApproveReward() async {\r\n    if (_scannedEnrollment == null || _scannedUserId == null) return;"
new = "  Future<void> _handleApproveReward() async {\r\n    if (_scannedEnrollment == null) return;"
assert old in text, '_handleApproveReward guard not found'
text = text.replace(old, new, 1)

# Fix _handleFulfillReward guard
old = "  Future<void> _handleFulfillReward() async {\r\n    if (_scannedEnrollment == null || _scannedUserId == null) return;"
new = "  Future<void> _handleFulfillReward() async {\r\n    if (_scannedEnrollment == null) return;"
# This might not exist (let's check and only replace if found)
if old in text:
    text = text.replace(old, new, 1)
    print("Fixed _handleFulfillReward guard")

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
