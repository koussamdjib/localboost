from django.conf import settings
from django.db import models

from apps.common.models import TimeStampedModel


class MerchantStatus(models.TextChoices):
	PENDING = "pending", "Pending"
	ACTIVE = "active", "Active"
	SUSPENDED = "suspended", "Suspended"


class MerchantProfile(TimeStampedModel):
	user = models.OneToOneField(
		settings.AUTH_USER_MODEL,
		on_delete=models.CASCADE,
		related_name="merchant_profile",
	)
	business_name = models.CharField(max_length=200)
	legal_name = models.CharField(max_length=200, blank=True)
	registration_number = models.CharField(max_length=120, blank=True)
	tax_number = models.CharField(max_length=120, blank=True)
	status = models.CharField(
		max_length=20,
		choices=MerchantStatus.choices,
		default=MerchantStatus.PENDING,
		db_index=True,
	)

	def __str__(self):
		return self.business_name
