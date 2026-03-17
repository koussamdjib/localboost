from django.db import models
from django.utils import timezone

from apps.common.models import TimeStampedModel


class FlyerFormat(models.TextChoices):
	IMAGE = "image", "Image"
	PDF = "pdf", "PDF"


class FlyerStatus(models.TextChoices):
	DRAFT = "draft", "Draft"
	PUBLISHED = "published", "Published"
	PAUSED = "paused", "Paused"
	EXPIRED = "expired", "Expired"


class Flyer(TimeStampedModel):
	shop = models.ForeignKey("shops.Shop", on_delete=models.CASCADE, related_name="flyers")
	title = models.CharField(max_length=180)
	description = models.TextField(blank=True)
	file = models.FileField(upload_to="flyers/", blank=True, null=True)
	file_url = models.URLField(blank=True)
	thumbnail_url = models.URLField(blank=True)
	file_format = models.CharField(max_length=10, choices=FlyerFormat.choices)
	status = models.CharField(
		max_length=16,
		choices=FlyerStatus.choices,
		default=FlyerStatus.DRAFT,
		db_index=True,
	)
	published_at = models.DateTimeField(null=True, blank=True)
	starts_at = models.DateTimeField(null=True, blank=True)
	ends_at = models.DateTimeField(null=True, blank=True)
	view_count = models.PositiveIntegerField(default=0)
	share_count = models.PositiveIntegerField(default=0)
	is_active = models.BooleanField(default=False)

	def save(self, *args, **kwargs):
		if self.status == FlyerStatus.PUBLISHED:
			self.is_active = True
			if self.published_at is None:
				self.published_at = timezone.now()
		else:
			self.is_active = False

		super().save(*args, **kwargs)

	def __str__(self):
		return self.title
