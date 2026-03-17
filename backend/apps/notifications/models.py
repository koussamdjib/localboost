from django.conf import settings
from django.db import models

from apps.common.models import TimeStampedModel


class NotificationChannel(models.TextChoices):
	IN_APP = "in_app", "In App"
	PUSH = "push", "Push"
	EMAIL = "email", "Email"
	SMS = "sms", "SMS"


class Notification(TimeStampedModel):
	recipient = models.ForeignKey(
		settings.AUTH_USER_MODEL,
		on_delete=models.CASCADE,
		related_name="notifications",
	)
	title = models.CharField(max_length=180)
	body = models.TextField()
	channel = models.CharField(
		max_length=20,
		choices=NotificationChannel.choices,
		default=NotificationChannel.IN_APP,
	)
	payload = models.JSONField(default=dict, blank=True)
	is_read = models.BooleanField(default=False)
	read_at = models.DateTimeField(null=True, blank=True)

	def __str__(self):
		return f"Notification<{self.recipient_id}:{self.channel}>"
