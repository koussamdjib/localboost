from rest_framework import serializers

from apps.enrollments.models import Enrollment
from apps.rewards.models import RedemptionStatus


class EnrollmentSerializer(serializers.ModelSerializer):
	user_id = serializers.SerializerMethodField()
	customer_name = serializers.SerializerMethodField()
	customer_email = serializers.SerializerMethodField()
	shop_id = serializers.SerializerMethodField()
	shop_name = serializers.SerializerMethodField()
	loyalty_program_id = serializers.SerializerMethodField()
	loyalty_program_name = serializers.SerializerMethodField()
	stamps_collected = serializers.IntegerField(source="stamps_count", read_only=True)
	stamps_required = serializers.SerializerMethodField()
	enrolled_at = serializers.DateTimeField(source="created_at", read_only=True)
	last_stamp_at = serializers.DateTimeField(source="last_activity_at", read_only=True)
	is_completed = serializers.SerializerMethodField()
	is_redeemed = serializers.SerializerMethodField()
	reward_status = serializers.SerializerMethodField()
	reward_request_id = serializers.SerializerMethodField()

	class Meta:
		model = Enrollment
		fields = [
			"id",
			"qr_token",
			"user_id",
			"customer_name",
			"customer_email",
			"shop_id",
			"shop_name",
			"loyalty_program_id",
			"loyalty_program_name",
			"stamps_collected",
			"stamps_required",
			"enrolled_at",
			"last_stamp_at",
			"is_completed",
			"is_redeemed",
			"reward_status",
			"reward_request_id",
		]

	def get_user_id(self, obj):
		return str(obj.customer.user_id)

	def get_customer_name(self, obj):
		profile = obj.customer
		full_name = f"{profile.first_name} {profile.last_name}".strip()
		if full_name:
			return full_name
		email = obj.customer.user.email
		return email.split("@")[0] if email else None

	def get_customer_email(self, obj):
		return obj.customer.user.email

	def get_shop_id(self, obj):
		return str(obj.loyalty_program.shop_id)

	def get_shop_name(self, obj):
		return obj.loyalty_program.shop.name

	def get_loyalty_program_id(self, obj):
		return str(obj.loyalty_program_id)

	def get_loyalty_program_name(self, obj):
		return obj.loyalty_program.name

	def get_stamps_required(self, obj):
		return int(obj.loyalty_program.stamps_required)

	def get_is_completed(self, obj):
		return int(obj.stamps_count) >= int(obj.loyalty_program.stamps_required)

	def get_is_redeemed(self, obj):
		return obj.redemptions.filter(status=RedemptionStatus.FULFILLED).exists()

	def _latest_active_request(self, obj):
		"""Return the most recent non-rejected redemption record, if any."""
		cache = getattr(self, "_latest_request_cache", None)
		if cache is None:
			cache = {}
			setattr(self, "_latest_request_cache", cache)

		obj_key = obj.pk
		if obj_key in cache:
			return cache[obj_key]

		prefetched = getattr(obj, "_prefetched_objects_cache", {}).get("redemptions")
		if prefetched is not None:
			candidates = [
				redemption
				for redemption in prefetched
				if redemption.status != RedemptionStatus.REJECTED
			]
			candidates.sort(key=lambda item: (item.created_at, item.id), reverse=True)
			latest = candidates[0] if candidates else None
		else:
			latest = (
				obj.redemptions
				.exclude(status=RedemptionStatus.REJECTED)
				.order_by("-created_at", "-id")
				.first()
			)

		cache[obj_key] = latest
		return latest

	def get_reward_status(self, obj):
		req = self._latest_active_request(obj)
		return req.status if req is not None else None

	def get_reward_request_id(self, obj):
		req = self._latest_active_request(obj)
		return req.id if req is not None else None