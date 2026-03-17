import 'package:localboost_shared/services/api/api_client.dart';

/// Simple model for backend-persisted in-app notifications
class ApiNotification {
  final int id;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final bool isRead;
  final DateTime createdAt;

  const ApiNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    required this.isRead,
    required this.createdAt,
  });

  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    return ApiNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  ApiNotification markRead() => ApiNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
        isRead: true,
        createdAt: createdAt,
      );
}

/// Fetches and manages backend in-app notifications
class ApiNotificationService {
  final ApiClient _client = ApiClient.instance;

  Future<({int unreadCount, List<ApiNotification> notifications})> fetchNotifications() async {
    final response = await _client.get('notifications/');
    final data = Map<String, dynamic>.from(response.data as Map);
    final results = (data['results'] as List<dynamic>? ?? [])
        .map((e) => ApiNotification.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (
      unreadCount: (data['unread_count'] as int?) ?? 0,
      notifications: results,
    );
  }

  Future<void> markAsRead(int id) async {
    await _client.patch('notifications/$id/', data: {'is_read': true});
  }

  Future<void> markAllRead() async {
    await _client.post('notifications/read-all/', data: {});
  }
}
