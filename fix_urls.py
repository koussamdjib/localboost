"""Edit enrollments/urls.py to add the scan/ endpoint."""
path = r'backend\apps\enrollments\urls.py'
with open(path, 'r', newline='') as f:
    text = f.read()

# Add EnrollmentScanView to imports
old = 'from apps.enrollments.views import (\r\n    EnrollmentDetailView,\r\n    EnrollmentListCreateView,\r\n    EnrollmentRedeemView,\r\n    EnrollmentStampHistoryView,\r\n    EnrollmentStampCreateView,\r\n)'
new = 'from apps.enrollments.views import (\r\n    EnrollmentDetailView,\r\n    EnrollmentListCreateView,\r\n    EnrollmentRedeemView,\r\n    EnrollmentScanView,\r\n    EnrollmentStampHistoryView,\r\n    EnrollmentStampCreateView,\r\n)'
assert old in text, 'imports block not found'
text = text.replace(old, new, 1)

# Add the scan URL
old = '    path("", EnrollmentListCreateView.as_view(), name="enrollment-list-create"),'
new = '    path("", EnrollmentListCreateView.as_view(), name="enrollment-list-create"),\r\n    path("scan/", EnrollmentScanView.as_view(), name="enrollment-scan"),'
assert old in text, 'urlpatterns not found'
text = text.replace(old, new, 1)

with open(path, 'w', newline='') as f:
    f.write(text)
print(f'Updated {path}')
