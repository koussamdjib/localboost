from django.conf import settings
from django.db import models

from apps.common.models import TimeStampedModel


class CustomerProfile(TimeStampedModel):
	user = models.OneToOneField(
		settings.AUTH_USER_MODEL,
		on_delete=models.CASCADE,
		related_name="customer_profile",
	)
	first_name = models.CharField(max_length=120, blank=True)
	last_name = models.CharField(max_length=120, blank=True)
	city = models.CharField(max_length=120, blank=True)
	country = models.CharField(max_length=120, blank=True)
	preferences = models.JSONField(default=dict, blank=True)

	def __str__(self):
		return f"CustomerProfile<{self.user.email}>"
