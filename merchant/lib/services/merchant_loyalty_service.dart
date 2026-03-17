import 'package:localboost_shared/services/api/api_client.dart';

class MerchantLoyaltyService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Map<String, dynamic>>> listPrograms(int shopId) async {
    final response = await _client.get('merchant/shops/$shopId/loyalty/');
    return _extractList(response.data);
  }

  Future<Map<String, dynamic>> createProgram({
    required int shopId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post(
      'merchant/shops/$shopId/loyalty/',
      data: payload,
    );
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> getProgram(int programId) async {
    final response = await _client.get('merchant/loyalty/$programId/');
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> updateProgram({
    required int programId,
    required Map<String, dynamic> payload,
    bool partial = false,
  }) async {
    final response = partial
        ? await _client.patch('merchant/loyalty/$programId/', data: payload)
        : await _client.put('merchant/loyalty/$programId/', data: payload);
    return _extractMap(response.data);
  }

  Future<void> deleteProgram(int programId) async {
    await _client.delete('merchant/loyalty/$programId/');
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
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

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const FormatException('Expected object response from loyalty API.');
  }
}