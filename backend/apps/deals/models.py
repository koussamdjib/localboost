from django.db import models

from apps.common.models import TimeStampedModel


class DealType(models.TextChoices):
	PERCENTAGE = "percentage", "Percentage"
	AMOUNT = "amount", "Amount"
	STAMP = "stamp", "Stamp"


class DealStatus(models.TextChoices):
	DRAFT = "draft", "Draft"
	PUBLISHED = "published", "Published"
	ARCHIVED = "archived", "Archived"


class Deal(TimeStampedModel):
	shop = models.ForeignKey("shops.Shop", on_delete=models.CASCADE, related_name="deals")
	title = models.CharField(max_length=180)
	description = models.TextField()
	deal_type = models.CharField(max_length=20, choices=DealType.choices)
	status = models.CharField(
		max_length=20,
		choices=DealStatus.choices,
		default=DealStatus.DRAFT,
		db_index=True,
	)
	image = models.ImageField(upload_to="deals/images/", blank=True)
	starts_at = models.DateTimeField(db_index=True)
	ends_at = models.DateTimeField(db_index=True)
	max_redemptions = models.PositiveIntegerField(null=True, blank=True)
	view_count = models.PositiveIntegerField(default=0)
	share_count = models.PositiveIntegerField(default=0)

	def __str__(self):
		return self.title
