from django.urls import path

from apps.enrollments.views import (
    EnrollmentDetailView,
    EnrollmentListCreateView,
    EnrollmentRedeemView,
    EnrollmentScanView,
    EnrollmentStampHistoryView,
    EnrollmentStampCreateView,
)

urlpatterns = [
    path("", EnrollmentListCreateView.as_view(), name="enrollment-list-create"),
    path("scan/", EnrollmentScanView.as_view(), name="enrollment-scan"),
    path("<int:id>/", EnrollmentDetailView.as_view(), name="enrollment-detail"),
    path("<int:id>/history/", EnrollmentStampHistoryView.as_view(), name="enrollment-history"),
    path("<int:id>/stamps/", EnrollmentStampCreateView.as_view(), name="enrollment-add-stamp"),
    path("<int:id>/redeem/", EnrollmentRedeemView.as_view(), name="enrollment-redeem"),
]
