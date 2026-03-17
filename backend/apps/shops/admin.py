from django.contrib import admin

from apps.shops.models import Shop


@admin.register(Shop)
class ShopAdmin(admin.ModelAdmin):
	list_display = ("id", "name", "category", "city", "country", "is_active")
	list_filter = ("is_active", "category", "city", "country")
	search_fields = ("name", "slug", "category", "city", "country")
