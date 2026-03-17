import uuid

from django.db import models
from apps.common.models import TimeStampedModel


class EnrollmentStatus(models.TextChoices):
	ACTIVE = "active", "Active"
	COMPLETED = "completed", "Completed"
	CANCELED = "canceled", "Canceled"


class Enrollment(TimeStampedModel):
	customer = models.ForeignKey(
		"customers.CustomerProfile",
		on_delete=models.CASCADE,
		related_name="enrollments",
		db_index=True,
	)
	loyalty_program = models.ForeignKey(
		"loyalty.LoyaltyProgram",
		on_delete=models.CASCADE,
		related_name="enrollments",
		db_index=True,
	)
	status = models.CharField(
		max_length=20,
		choices=EnrollmentStatus.choices,
		default=EnrollmentStatus.ACTIVE,
		db_index=True,
	)
	stamps_count = models.PositiveIntegerField(default=0)
	last_activity_at = models.DateTimeField(null=True, blank=True)
	qr_token = models.UUIDField(
		default=uuid.uuid4,
		unique=True,
		editable=False,
		db_index=True,
	)

	class Meta:
		constraints = [
			models.UniqueConstraint(
				fields=["customer", "loyalty_program"], name="uq_customer_loyalty_enrollment"
			)
		]

	def __str__(self):
		return f"Enrollment<{self.customer_id}:{self.loyalty_program_id}>"
