from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from apps.accounts.models import UserRole
from apps.customers.models import CustomerProfile
from apps.merchants.models import MerchantProfile

User = get_user_model()


class RegistrationRoleFlowTests(APITestCase):
	def setUp(self):
		self.register_url = reverse("user-register")
		self.token_url = reverse("token-obtain-pair")
		self.me_url = reverse("current-user")

	def test_register_defaults_to_customer_role(self):
		payload = {
			"email": "customer-role-check@test.com",
			"password": "TestPass123!",
			"name": "Customer Test",
			"phone_number": "+25377112233",
		}

		response = self.client.post(self.register_url, payload, format="json")

		self.assertEqual(response.status_code, status.HTTP_201_CREATED)
		self.assertEqual(response.data["role"], UserRole.CUSTOMER)

		user = User.objects.get(email=payload["email"])
		self.assertEqual(user.role, UserRole.CUSTOMER)
		self.assertTrue(CustomerProfile.objects.filter(user=user).exists())
		self.assertFalse(MerchantProfile.objects.filter(user=user).exists())

	def test_register_merchant_creates_merchant_profile_only(self):
		payload = {
			"email": "merchant-role-check@test.com",
			"password": "TestPass123!",
			"name": "Merchant Test",
			"role": UserRole.MERCHANT,
		}

		response = self.client.post(self.register_url, payload, format="json")

		self.assertEqual(response.status_code, status.HTTP_201_CREATED)
		self.assertEqual(response.data["role"], UserRole.MERCHANT)

		user = User.objects.get(email=payload["email"])
		self.assertEqual(user.role, UserRole.MERCHANT)
		self.assertTrue(MerchantProfile.objects.filter(user=user).exists())
		self.assertFalse(CustomerProfile.objects.filter(user=user).exists())

	def test_current_user_response_exposes_role(self):
		user = User.objects.create_user(
			email="merchant-me-role@test.com",
			username="merchant-me-role",
			password="TestPass123!",
			role=UserRole.MERCHANT,
		)
		MerchantProfile.objects.create(user=user, business_name="Merchant Role QA")

		token_response = self.client.post(
			self.token_url,
			{"email": user.email, "password": "TestPass123!"},
			format="json",
		)
		self.assertEqual(token_response.status_code, status.HTTP_200_OK)
		access_token = token_response.data["access"]

		self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")
		me_response = self.client.get(self.me_url)

		self.assertEqual(me_response.status_code, status.HTTP_200_OK)
		self.assertEqual(me_response.data["role"], UserRole.MERCHANT)


class EmailUpdateFlowTests(APITestCase):
	def setUp(self):
		self.user = User.objects.create_user(
			email="email-update@test.com",
			username="email_update",
			password="TestPass123!",
			role=UserRole.CUSTOMER,
		)
		CustomerProfile.objects.create(user=self.user)

		self.other_user = User.objects.create_user(
			email="already-used@test.com",
			username="already_used",
			password="TestPass123!",
			role=UserRole.CUSTOMER,
		)
		CustomerProfile.objects.create(user=self.other_user)

		self.email_update_url = reverse("current-user-email-update")

	def test_user_can_update_email_with_correct_password(self):
		self.client.force_authenticate(user=self.user)

		response = self.client.post(
			self.email_update_url,
			{"new_email": "new-email@test.com", "password": "TestPass123!"},
			format="json",
		)

		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.assertEqual(response.data["user"]["email"], "new-email@test.com")

		self.user.refresh_from_db()
		self.assertEqual(self.user.email, "new-email@test.com")
		self.assertFalse(self.user.is_email_verified)

	def test_email_update_rejects_wrong_password(self):
		self.client.force_authenticate(user=self.user)

		response = self.client.post(
			self.email_update_url,
			{"new_email": "new-email@test.com", "password": "WrongPass123!"},
			format="json",
		)

		self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
		self.user.refresh_from_db()
		self.assertEqual(self.user.email, "email-update@test.com")

	def test_email_update_rejects_existing_email(self):
		self.client.force_authenticate(user=self.user)

		response = self.client.post(
			self.email_update_url,
			{"new_email": "already-used@test.com", "password": "TestPass123!"},
			format="json",
		)

		self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
		self.user.refresh_from_db()
		self.assertEqual(self.user.email, "email-update@test.com")
