from django.conf import settings
from django.db import models

from apps.common.models import TimeStampedModel


class RedemptionStatus(models.TextChoices):
	REQUESTED = "requested", "Requested"
	APPROVED = "approved", "Approved"
	REJECTED = "rejected", "Rejected"
	FULFILLED = "fulfilled", "Fulfilled"


class RewardRedemption(TimeStampedModel):
	enrollment = models.ForeignKey(
		"enrollments.Enrollment",
		on_delete=models.CASCADE,
		related_name="redemptions",
		db_index=True,
	)
	deal = models.ForeignKey(
		"deals.Deal",
		on_delete=models.SET_NULL,
		null=True,
		blank=True,
		related_name="redemptions",
		db_index=True,
	)
	reward_label = models.CharField(max_length=180)
	status = models.CharField(
		max_length=20,
		choices=RedemptionStatus.choices,
		default=RedemptionStatus.REQUESTED,
		db_index=True,
	)
	approved_by = models.ForeignKey(
		settings.AUTH_USER_MODEL,
		on_delete=models.SET_NULL,
		null=True,
		blank=True,
		related_name="approved_redemptions",
	)
	redeemed_at = models.DateTimeField(null=True, blank=True)

	def __str__(self):
		return f"RewardRedemption<{self.enrollment_id}:{self.status}>"
