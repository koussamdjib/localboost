from django.contrib import admin
from django.contrib.auth.admin import UserAdmin

from apps.accounts.models import User


@admin.register(User)
class LocalBoostUserAdmin(UserAdmin):
	list_display = ("email", "username", "role", "is_staff", "is_active")
	ordering = ("email",)

	fieldsets = UserAdmin.fieldsets + (
		(
			"LocalBoost",
			{
				"fields": (
					"role",
					"phone_number",
					"is_email_verified",
				)
			},
		),
	)

