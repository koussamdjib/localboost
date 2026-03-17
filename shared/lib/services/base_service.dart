import 'package:localboost_shared/services/api/api_client.dart';

/// Base class for shared service utilities and patterns.
abstract class BaseService {
  final ApiClient client = ApiClient.instance;

  /// Extract list of items from API response data.
  /// Handles both direct list and paginated {results: []} format.
  List<Map<String, dynamic>> extractList(dynamic data) {
    final items = <dynamic>[];

    if (data is List) {
      items.addAll(data);
    } else if (data is Map && data['results'] is List) {
      items.addAll(data['results'] as List);
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  /// Extract single map object from API response data.
  /// Handles nested response structures.
  Map<String, dynamic> extractMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
