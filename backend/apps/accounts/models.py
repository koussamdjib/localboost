from django.contrib.auth.models import AbstractUser
from django.db import models

from apps.accounts.managers import UserManager
from apps.common.models import TimeStampedModel


class UserRole(models.TextChoices):
	CUSTOMER = "customer", "Customer"
	MERCHANT = "merchant", "Merchant"
	ADMIN = "admin", "Admin"


class User(AbstractUser, TimeStampedModel):
	email = models.EmailField(unique=True)
	role = models.CharField(
		max_length=20,
		choices=UserRole.choices,
		default=UserRole.CUSTOMER,
		db_index=True,
	)
	phone_number = models.CharField(max_length=32, blank=True)
	is_email_verified = models.BooleanField(default=False)

	objects = UserManager()

	USERNAME_FIELD = "email"
	REQUIRED_FIELDS = ["username"]

	def __str__(self):
		return self.email
