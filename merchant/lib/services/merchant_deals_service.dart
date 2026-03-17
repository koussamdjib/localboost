import 'package:localboost_shared/services/api/api_client.dart';

class MerchantDealsService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Map<String, dynamic>>> listDeals(int shopId) async {
    final response = await _client.get('merchant/shops/$shopId/deals/');
    return _extractList(response.data);
  }

  Future<Map<String, dynamic>> createDeal({
    required int shopId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _client.post(
      'merchant/shops/$shopId/deals/',
      data: payload,
    );
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> getDeal(int dealId) async {
    final response = await _client.get('merchant/deals/$dealId/');
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> trackDealView(int dealId) async {
    final response = await _client.post('merchant/deals/$dealId/view/');
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> trackDealShare(int dealId) async {
    final response = await _client.post('merchant/deals/$dealId/share/');
    return _extractMap(response.data);
  }

  Future<Map<String, dynamic>> updateDeal({
    required int dealId,
    required Map<String, dynamic> payload,
    bool partial = false,
  }) async {
    final response = partial
        ? await _client.patch('merchant/deals/$dealId/', data: payload)
        : await _client.put('merchant/deals/$dealId/', data: payload);
    return _extractMap(response.data);
  }

  Future<void> deleteDeal(int dealId) async {
    await _client.delete('merchant/deals/$dealId/');
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
    throw const FormatException('Expected object response from deals API.');
  }
}