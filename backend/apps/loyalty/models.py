from django.db import models

from apps.common.models import TimeStampedModel


class LoyaltyProgram(TimeStampedModel):
	shop = models.ForeignKey(
		"shops.Shop",
		on_delete=models.CASCADE,
		related_name="loyalty_programs",
	)
	name = models.CharField(max_length=180)
	description = models.TextField(blank=True)
	stamps_required = models.PositiveIntegerField(default=10)
	reward_label = models.CharField(max_length=180)
	is_active = models.BooleanField(default=True)

	def __str__(self):
		return self.name
