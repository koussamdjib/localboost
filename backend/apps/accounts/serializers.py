from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core import exceptions as django_exceptions
from django.db.models import Count, Q, Sum
from rest_framework import serializers

from apps.accounts.models import UserRole

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    """
    Serializer for User model exposed to Flutter clients.
    Includes computed fields for customer stats.
    """

    name = serializers.SerializerMethodField()
    total_stamps = serializers.SerializerMethodField()
    total_rewards_redeemed = serializers.SerializerMethodField()
    total_offers_joined = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = [
            "id",
            "email",
            "role",
            "name",
            "phone_number",
            "created_at",
            "last_login",
            "total_stamps",
            "total_rewards_redeemed",
            "total_offers_joined",
        ]
        read_only_fields = [
            "id",
            "email",
            "role",
            "created_at",
            "last_login",
            "total_stamps",
            "total_rewards_redeemed",
            "total_offers_joined",
        ]

    def get_name(self, obj):
        """Return username or full name if available."""
        if obj.first_name and obj.last_name:
            return f"{obj.first_name} {obj.last_name}"
        return obj.username or obj.email.split("@")[0]


    def get_total_stamps(self, obj):
        """
        Calculate total stamps earned across all enrollments.
        Returns sum of all stamp transactions for this customer.
        """
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.transactions.models import StampTransaction

        total = StampTransaction.objects.filter(
            enrollment__customer=obj.customer_profile
        ).aggregate(total=Sum("quantity"))["total"]

        return total or 0

    def get_total_rewards_redeemed(self, obj):
        """
        Calculate total rewards redeemed.
        Returns count of fulfilled redemptions for this customer.
        """
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.rewards.models import RewardRedemption, RedemptionStatus

        count = RewardRedemption.objects.filter(
            enrollment__customer=obj.customer_profile,
            status=RedemptionStatus.FULFILLED,
        ).count()

        return count

    def get_total_offers_joined(self, obj):
        """
        Calculate total loyalty programs joined.
        Returns count of enrollments for this customer.
        """
        if not hasattr(obj, "customer_profile"):
            return 0

        from apps.enrollments.models import Enrollment

        count = Enrollment.objects.filter(customer=obj.customer_profile).count()

        return count


class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration.
    Creates a new user account.
    """

    password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})
    name = serializers.CharField(write_only=True, required=False, allow_blank=True)
    role = serializers.ChoiceField(
        choices=[UserRole.CUSTOMER, UserRole.MERCHANT],
        required=False,
        default=UserRole.CUSTOMER,
    )

    class Meta:
        model = User
        fields = ["email", "password", "name", "phone_number", "role"]

    def validate_password(self, value):
        """Validate password using Django's password validators."""
        try:
            validate_password(value)
        except django_exceptions.ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

    def validate_email(self, value):
        """Ensure email is unique and valid."""
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value.lower()

    def create(self, validated_data):
        """Create new user with hashed password and role-aware profile."""
        from apps.customers.models import CustomerProfile
        from apps.merchants.models import MerchantProfile

        name = validated_data.pop("name", "")
        password = validated_data.pop("password")
        role = validated_data.pop("role", UserRole.CUSTOMER)

        # Set username to email prefix if not provided
        if "username" not in validated_data:
            validated_data["username"] = validated_data["email"].split("@")[0]

        # Create user
        user = User.objects.create_user(password=password, role=role, **validated_data)

        # Parse name if provided
        if name:
            parts = name.strip().split(None, 1)
            user.first_name = parts[0]
            if len(parts) > 1:
                user.last_name = parts[1]
            user.save(update_fields=["first_name", "last_name"])

        if role == UserRole.MERCHANT:
            business_name = (name.strip() or user.username or user.email.split("@")[0])[:200]
            MerchantProfile.objects.create(user=user, business_name=business_name)
        else:
            CustomerProfile.objects.create(
                user=user,
                first_name=user.first_name,
                last_name=user.last_name,
            )

        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    """
    Serializer for updating user profile.
    Allows updating name and phone number.
    """

    name = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ["name", "phone_number"]

    def update(self, instance, validated_data):
        """Update user profile with name parsing."""
        name = validated_data.pop("name", None)

        # Update phone number if provided
        if "phone_number" in validated_data:
            instance.phone_number = validated_data["phone_number"]

        # Parse and update name if provided
        if name is not None:
            parts = name.strip().split(None, 1) if name else []
            instance.first_name = parts[0] if len(parts) > 0 else ""
            instance.last_name = parts[1] if len(parts) > 1 else ""

        instance.save()

        # Sync CustomerProfile so enrollment lists reflect updated name
        if name is not None and hasattr(instance, "customer_profile"):
            profile = instance.customer_profile
            profile.first_name = instance.first_name
            profile.last_name = instance.last_name
            profile.save(update_fields=["first_name", "last_name"])

        return instance


class UserEmailUpdateSerializer(serializers.Serializer):
    """Serializer for changing the authenticated user's email."""

    new_email = serializers.EmailField(required=True)
    password = serializers.CharField(
        write_only=True,
        required=True,
        style={"input_type": "password"},
    )

    def validate_password(self, value):
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError("Current password is incorrect.")
        return value

    def validate_new_email(self, value):
        normalized_email = value.lower().strip()
        user = self.context["request"].user
        if user.email.lower() == normalized_email:
            raise serializers.ValidationError("New email must be different.")

        if User.objects.filter(email__iexact=normalized_email).exclude(pk=user.pk).exists():
            raise serializers.ValidationError("A user with this email already exists.")

        return normalized_email

    def save(self):
        user = self.context["request"].user
        user.email = self.validated_data["new_email"]
        user.is_email_verified = False
        user.save(update_fields=["email", "is_email_verified"])
        return user


class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer for changing user password.
    Requires old password and new password.
    """

    old_password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})
    new_password = serializers.CharField(write_only=True, required=True, style={"input_type": "password"})

    def validate_old_password(self, value):
        """Verify old password is correct."""
        user = self.context["request"].user
        if not user.check_password(value):
            raise serializers.ValidationError("Old password is incorrect.")
        return value

    def validate_new_password(self, value):
        """Validate new password using Django's validators."""
        try:
            validate_password(value, user=self.context["request"].user)
        except django_exceptions.ValidationError as e:
            raise serializers.ValidationError(list(e.messages))
        return value

    def save(self):
        """Update user's password."""
        user = self.context["request"].user
        user.set_password(self.validated_data["new_password"])
        user.save(update_fields=["password"])
        return user
