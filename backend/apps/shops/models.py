from django.db import models

from apps.common.models import TimeStampedModel


class ShopStatus(models.TextChoices):
	DRAFT = "draft", "Draft"
	ACTIVE = "active", "Active"
	SUSPENDED = "suspended", "Suspended"
	ARCHIVED = "archived", "Archived"


class Shop(TimeStampedModel):
	merchant = models.ForeignKey(
		"merchants.MerchantProfile",
		on_delete=models.CASCADE,
		related_name="shops",
	)
	name = models.CharField(max_length=180)
	slug = models.SlugField(unique=True)
	category = models.CharField(max_length=100, blank=True, default="", db_index=True)
	description = models.TextField(blank=True)
	logo_url = models.URLField(blank=True)
	cover_image_url = models.URLField(blank=True)
	phone_number = models.CharField(max_length=32, blank=True)
	email = models.EmailField(blank=True)
	business_hours = models.JSONField(default=dict, blank=True)
	address_line_1 = models.CharField(max_length=255)
	address_line_2 = models.CharField(max_length=255, blank=True)
	city = models.CharField(max_length=120)
	country = models.CharField(max_length=120)
	latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
	longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
	status = models.CharField(
		max_length=20,
		choices=ShopStatus.choices,
		default=ShopStatus.ACTIVE,
		db_index=True,
	)
	is_active = models.BooleanField(default=True)

	def __str__(self):
		return self.name
