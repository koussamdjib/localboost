from datetime import timedelta

from django.db.models import Count, Sum
from django.utils import timezone
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import UserRole
from apps.common.mixins import ProfileAccessMixin
from apps.enrollments.models import Enrollment, EnrollmentStatus
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.transactions.models import StampTransaction, StampTransactionType


class CustomerAnalyticsView(ProfileAccessMixin, APIView):
    """
    GET /api/v1/analytics/customers/

    Merchant-only. Returns customer engagement stats for the merchant's shop.

    Response:
    {
        "total_customers": int,
        "active_customers": int,       # enrolled and not canceled
        "completed_cards": int,        # cards that reached stamp goal
        "stamps_this_week": int,
        "stamps_this_month": int,
        "reward_redemptions": int,
        "redemption_rate": float,      # completed / total, 0-1
        "top_customers": [
            {"name": str, "email": str, "stamps": int, "is_completed": bool},
            ...
        ]
    }
    """

    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        if user.role != UserRole.MERCHANT:
            from rest_framework.exceptions import PermissionDenied
            raise PermissionDenied("Merchant access only.")

        merchant = self._merchant_profile_for_user(user)
        shop_id = request.query_params.get("shop_id")

        enrollment_qs = Enrollment.objects.filter(
            loyalty_program__shop__merchant=merchant,
        ).exclude(status=EnrollmentStatus.CANCELED)

        if shop_id:
            enrollment_qs = enrollment_qs.filter(loyalty_program__shop_id=shop_id)

        now = timezone.now()
        week_ago = now - timedelta(days=7)
        month_ago = now - timedelta(days=30)

        total = enrollment_qs.count()
        active = enrollment_qs.filter(status=EnrollmentStatus.ACTIVE).count()
        completed = enrollment_qs.filter(status=EnrollmentStatus.COMPLETED).count()

        # Stamp events
        stamp_qs = StampTransaction.objects.filter(
            enrollment__in=enrollment_qs,
            transaction_type=StampTransactionType.EARN,
        )
        stamps_week = stamp_qs.filter(created_at__gte=week_ago).aggregate(
            total=Sum("quantity")
        )["total"] or 0
        stamps_month = stamp_qs.filter(created_at__gte=month_ago).aggregate(
            total=Sum("quantity")
        )["total"] or 0

        # Reward redemptions
        redemptions = RewardRedemption.objects.filter(
            enrollment__in=enrollment_qs,
            status=RedemptionStatus.FULFILLED,
        ).count()

        redemption_rate = round(completed / total, 4) if total > 0 else 0.0

        # Top 10 customers by stamps
        top = (
            enrollment_qs.select_related("customer__user")
            .order_by("-stamps_count")[:10]
        )
        top_customers = [
            {
                "name": e.customer.user.name if e.customer.user else "",
                "email": e.customer.user.email if e.customer.user else "",
                "stamps": e.stamps_count,
                "stamps_required": e.loyalty_program.stamps_required,
                "is_completed": e.status == EnrollmentStatus.COMPLETED,
            }
            for e in top
        ]

        return Response({
            "total_customers": total,
            "active_customers": active,
            "completed_cards": completed,
            "stamps_this_week": stamps_week,
            "stamps_this_month": stamps_month,
            "reward_redemptions": redemptions,
            "redemption_rate": redemption_rate,
            "top_customers": top_customers,
        })
