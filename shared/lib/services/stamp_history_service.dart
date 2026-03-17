import 'package:localboost_shared/models/stamp_history.dart';
import 'package:localboost_shared/services/api/api_client.dart';

class StampHistoryService {
  final ApiClient _client = ApiClient.instance;

  Future<List<StampHistory>> fetchStampHistory({
    required String enrollmentId,
  }) async {
    final response = await _client.get('enrollments/$enrollmentId/history/');
    final payload = response.data;
    final rawItems = _extractListPayload(payload);

    return rawItems
        .whereType<Map>()
        .map(
          (item) => StampHistory.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'];
      if (results is List) {
        return results;
      }

      final data = payload['data'];
      if (data is List) {
        return data;
      }
    }

    return const <dynamic>[];
  }
}
