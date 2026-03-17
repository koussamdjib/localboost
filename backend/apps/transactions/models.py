from django.conf import settings
from django.db import models

from apps.common.models import TimeStampedModel


class StampTransactionType(models.TextChoices):
	EARN = "earn", "Earn"
	ADJUSTMENT = "adjustment", "Adjustment"
	REVERSAL = "reversal", "Reversal"


class StampTransaction(TimeStampedModel):
	enrollment = models.ForeignKey(
		"enrollments.Enrollment",
		on_delete=models.CASCADE,
		related_name="stamp_transactions",
	)
	performed_by = models.ForeignKey(
		settings.AUTH_USER_MODEL,
		on_delete=models.SET_NULL,
		null=True,
		blank=True,
		related_name="performed_stamp_transactions",
	)
	transaction_type = models.CharField(max_length=20, choices=StampTransactionType.choices)
	quantity = models.PositiveIntegerField(default=1)
	reference = models.CharField(max_length=120, blank=True)
	notes = models.TextField(blank=True)
	idempotency_key = models.CharField(max_length=64, blank=True, db_index=True)

	class Meta:
		constraints = [
			models.UniqueConstraint(
				fields=['enrollment', 'idempotency_key'],
				condition=models.Q(idempotency_key__gt=''),
				name='uq_stamp_transaction_idempotency',
			)
		]

	def __str__(self):
		return f"StampTransaction<{self.enrollment_id}:{self.transaction_type}>"
