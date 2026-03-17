"""Edit enrollments/views.py:
1. Add EnrollmentScanView after imports
2. Update stamp endpoint: remove user_id check, add idempotency check
"""
from django.db import IntegrityError

path = r'backend\apps\enrollments\views.py'
with open(path, 'r', newline='') as f:
    text = f.read()

# ---------------------------------------------------------------
# 1. Update stamp endpoint: remove user_id block + add idempotency
# ---------------------------------------------------------------
OLD_USER_ID_CHECK = (
    '\r\n\t\t\texpected_user_id = request.data.get("user_id")\r\n'
    '\t\t\tif expected_user_id not in (None, "") and str(enrollment.customer.user_id) != str(\r\n'
    '\t\t\t\texpected_user_id\r\n'
    '\t\t\t):\r\n'
    '\t\t\t\traise ValidationError({"user_id": "Scanned user does not match this enrollment."})\r\n'
    '\r\n'
    '\t\t\tenrollment.stamps_count += quantity'
)
NEW_IDEMPOTENCY = (
    '\r\n'
    '\t\t\t# Idempotency: if a key is provided, skip if already processed\r\n'
    '\t\t\tidempotency_key = (request.data.get("idempotency_key") or "").strip()\r\n'
    '\r\n'
    '\t\t\tif idempotency_key and StampTransaction.objects.filter(\r\n'
    '\t\t\t\tenrollment=enrollment,\r\n'
    '\t\t\t\tidempotency_key=idempotency_key,\r\n'
    '\t\t\t).exists():\r\n'
    '\t\t\t\tserializer = EnrollmentSerializer(enrollment)\r\n'
    '\t\t\t\treturn Response(serializer.data, status=status.HTTP_200_OK)\r\n'
    '\r\n'
    '\t\t\tenrollment.stamps_count += quantity'
)

assert OLD_USER_ID_CHECK in text, 'user_id check block not found in views.py'
text = text.replace(OLD_USER_ID_CHECK, NEW_IDEMPOTENCY, 1)

# Also persist idempotency_key when creating StampTransaction
OLD_CREATE = (
    '\t\t\tStampTransaction.objects.create(\r\n'
    '\t\t\t\tenrollment=enrollment,\r\n'
    '\t\t\t\tperformed_by=request.user,\r\n'
    '\t\t\t\ttransaction_type=StampTransactionType.EARN,\r\n'
    '\t\t\t\tquantity=quantity,\r\n'
    '\t\t\t\treference="merchant_scan",\r\n'
    '\t\t\t\tnotes=(request.data.get("note") or "").strip(),\r\n'
    '\t\t\t)'
)
NEW_CREATE = (
    '\t\t\tStampTransaction.objects.create(\r\n'
    '\t\t\t\tenrollment=enrollment,\r\n'
    '\t\t\t\tperformed_by=request.user,\r\n'
    '\t\t\t\ttransaction_type=StampTransactionType.EARN,\r\n'
    '\t\t\t\tquantity=quantity,\r\n'
    '\t\t\t\treference="merchant_scan",\r\n'
    '\t\t\t\tnotes=(request.data.get("note") or "").strip(),\r\n'
    '\t\t\t\tidempotency_key=idempotency_key,\r\n'
    '\t\t\t)'
)
assert OLD_CREATE in text, 'StampTransaction.objects.create block not found'
text = text.replace(OLD_CREATE, NEW_CREATE, 1)

# ---------------------------------------------------------------
# 2. Append EnrollmentScanView at end of file
# ---------------------------------------------------------------
SCAN_VIEW = '''

class EnrollmentScanView(EnrollmentBaseMixin, APIView):
\t"""
\tPOST /api/v1/enrollments/scan/

\tMerchant-only: resolve a QR token to an enrollment for the merchant's shop.
\tReturns the enrollment data so the merchant can decide to stamp or redeem.
\t"""

\tpermission_classes = [IsAuthenticated]

\tdef post(self, request):
\t\tif request.user.role != UserRole.MERCHANT:
\t\t\traise PermissionDenied("Only merchants can resolve QR tokens.")

\t\tqr_token = (request.data.get("qr_token") or "").strip()
\t\tif not qr_token:
\t\t\traise ValidationError({"qr_token": "This field is required."})

\t\ttry:
\t\t\timport uuid as _uuid
\t\t\tparsed_token = _uuid.UUID(qr_token)
\t\texcept ValueError:
\t\t\traise ValidationError({"qr_token": "Invalid QR token format."})

\t\tmerchant = self._merchant_profile_for_user(request.user)
\t\ttry:
\t\t\tenrollment = (
\t\t\t\tEnrollment.objects.select_related(
\t\t\t\t\t"customer__user",
\t\t\t\t\t"loyalty_program__shop",
\t\t\t\t\t"loyalty_program__shop__merchant",
\t\t\t\t)
\t\t\t\t.prefetch_related("redemptions")
\t\t\t\t.get(qr_token=parsed_token)
\t\t\t)
\t\texcept Enrollment.DoesNotExist:
\t\t\traise ValidationError({"qr_token": "No enrollment found for this QR code."})

\t\tif not self._owned_by_merchant(enrollment):
\t\t\traise PermissionDenied("This enrollment does not belong to your shop.")

\t\tif enrollment.status == EnrollmentStatus.CANCELED:
\t\t\traise ValidationError({"detail": "This enrollment has been canceled."})

\t\tserializer = EnrollmentSerializer(enrollment)
\t\treturn Response(serializer.data, status=status.HTTP_200_OK)
'''

text = text.rstrip() + SCAN_VIEW

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
