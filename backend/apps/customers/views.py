from rest_framework import serializers, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.customers.models import CustomerProfile


class CustomerProfileSerializer(serializers.ModelSerializer):
	class Meta:
		model = CustomerProfile
		fields = ["first_name", "last_name", "city", "country", "preferences"]


class CustomerMeView(APIView):
	"""
	GET  /api/v1/customers/me/  — return customer profile fields
	PATCH /api/v1/customers/me/ — update city / country / preferences
	"""

	permission_classes = [IsAuthenticated]

	def _get_profile(self):
		try:
			return self.request.user.customer_profile
		except CustomerProfile.DoesNotExist:
			return None

	def get(self, request):
		profile = self._get_profile()
		if profile is None:
			return Response({"city": "", "country": "", "preferences": {}})
		return Response(CustomerProfileSerializer(profile).data)

	def patch(self, request):
		profile = self._get_profile()
		if profile is None:
			return Response(
				{"detail": "Customer profile not found."},
				status=status.HTTP_404_NOT_FOUND,
			)
		serializer = CustomerProfileSerializer(profile, data=request.data, partial=True)
		serializer.is_valid(raise_exception=True)
		serializer.save()
		return Response(serializer.data)

