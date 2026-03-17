from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class HealthEndpointTests(APITestCase):
	def test_health_root_reports_service_and_checks(self):
		response = self.client.get(reverse("health-check"))
		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.assertEqual(response.data["status"], "ok")
		self.assertIn("service", response.data)
		self.assertIn("checks", response.data)
		self.assertIn("database", response.data["checks"])
		self.assertIn("migrations", response.data["checks"])
		self.assertIn("cache", response.data["checks"])

	def test_health_db_reports_database_and_migrations(self):
		response = self.client.get(reverse("health-db"))
		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.assertEqual(response.data["status"], "ok")
		self.assertIn("checks", response.data)
		self.assertIn("database", response.data["checks"])
		self.assertIn("migrations", response.data["checks"])

	def test_health_cache_reports_cache_status(self):
		response = self.client.get(reverse("health-cache"))
		self.assertEqual(response.status_code, status.HTTP_200_OK)
		self.assertEqual(response.data["status"], "ok")
		self.assertIn("checks", response.data)
		self.assertIn("cache", response.data["checks"])
