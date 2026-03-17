from rest_framework import serializers

from apps.loyalty.models import LoyaltyProgram


class LoyaltyProgramSerializer(serializers.ModelSerializer):
	shop_id = serializers.IntegerField(read_only=True)
	enrollment_count = serializers.SerializerMethodField()
	active_members = serializers.SerializerMethodField()
	redemption_count = serializers.SerializerMethodField()
	total_stamps_granted = serializers.SerializerMethodField()

	class Meta:
		model = LoyaltyProgram
		fields = [
			"id",
			"shop_id",
			"name",
			"description",
			"stamps_required",
			"reward_label",
			"is_active",
			"enrollment_count",
			"active_members",
			"redemption_count",
			"total_stamps_granted",
			"created_at",
			"updated_at",
		]
		read_only_fields = [
			"id",
			"shop_id",
			"created_at",
			"updated_at",
		]
		extra_kwargs = {
			"description": {"required": False},
			"is_active": {"required": False},
		}

	def validate_stamps_required(self, value):
		if value < 1:
			raise serializers.ValidationError("Stamps required must be at least 1.")
		return value

	def validate(self, attrs):
		name = attrs.get("name")
		reward_label = attrs.get("reward_label")
		stamps_required = attrs.get("stamps_required")

		if self.instance is not None:
			if name is None:
				name = self.instance.name
			if reward_label is None:
				reward_label = self.instance.reward_label
			if stamps_required is None:
				stamps_required = self.instance.stamps_required

		# Ensure required fields have values for create and partial update flows.
		if not name:
			raise serializers.ValidationError({"name": "Name is required."})
		if not reward_label:
			raise serializers.ValidationError({"reward_label": "Reward label is required."})
		if stamps_required is None:
			attrs["stamps_required"] = 10  # Default value
		return attrs

	def get_enrollment_count(self, obj):
		return obj.enrollments.count()

	def get_active_members(self, obj):
		return obj.enrollments.filter(status="active").count()

	def get_redemption_count(self, obj):
		from apps.rewards.models import RewardRedemption
		return RewardRedemption.objects.filter(
			enrollment__loyalty_program=obj
		).count()

	def get_total_stamps_granted(self, obj):
		from django.db.models import Sum
		result = obj.enrollments.aggregate(total=Sum("stamps_count"))
		return result["total"] or 0
