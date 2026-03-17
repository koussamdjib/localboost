from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.notifications.models import Notification
from apps.notifications.serializers import NotificationSerializer


class NotificationListView(APIView):
	"""
	GET  /api/v1/notifications/        — paginated list for current user
	POST /api/v1/notifications/read-all/ — mark all as read (handled separately)
	"""

	permission_classes = [IsAuthenticated]

	def get(self, request):
		qs = (
			Notification.objects
			.filter(recipient=request.user)
			.order_by("-created_at")[:50]
		)
		serializer = NotificationSerializer(qs, many=True)
		unread_count = Notification.objects.filter(
			recipient=request.user, is_read=False
		).count()
		return Response({
			"count": len(serializer.data),
			"unread_count": unread_count,
			"results": serializer.data,
		})


class NotificationDetailView(APIView):
	"""
	PATCH /api/v1/notifications/{id}/  — mark single notification as read
	"""

	permission_classes = [IsAuthenticated]

	def patch(self, request, pk):
		try:
			notification = Notification.objects.get(pk=pk, recipient=request.user)
		except Notification.DoesNotExist:
			return Response(status=status.HTTP_404_NOT_FOUND)

		if not notification.is_read:
			notification.is_read = True
			notification.read_at = timezone.now()
			notification.save(update_fields=["is_read", "read_at"])

		return Response(NotificationSerializer(notification).data)


class NotificationMarkAllReadView(APIView):
	"""
	POST /api/v1/notifications/read-all/
	"""

	permission_classes = [IsAuthenticated]

	def post(self, request):
		updated = Notification.objects.filter(
			recipient=request.user, is_read=False
		).update(is_read=True, read_at=timezone.now())
		return Response({"marked_read": updated})

