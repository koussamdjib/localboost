import 'package:localboost_shared/models/shop_discovery_shop.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:localboost_shared/services/api/api_response.dart';

class ShopEndpoints {
  final ApiClient _client = ApiClient.instance;

  Future<ApiResponse<List<ShopDiscoveryShop>>> listShops({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final response = await _client.get(
      'shops/',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );

    return ApiResponse<List<ShopDiscoveryShop>>(
      data: _parseShopListPayload(response.data),
      statusCode: response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<List<ShopDiscoveryShop>>> searchShops({
    String? name,
    String? category,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    final response = await _client.get(
      'shops/search/',
      queryParameters: {
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radiusKm != null) 'radius': radiusKm,
      },
    );

    return ApiResponse<List<ShopDiscoveryShop>>(
      data: _parseShopListPayload(response.data),
      statusCode: response.statusCode ?? 200,
    );
  }

  Future<ApiResponse<ShopDiscoveryShop>> getShopDetail(
    int shopId, {
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.get(
      'shops/$shopId/',
      queryParameters: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );

    final payload = Map<String, dynamic>.from(response.data as Map);

    return ApiResponse<ShopDiscoveryShop>(
      data: ShopDiscoveryShop.fromJson(payload),
      statusCode: response.statusCode ?? 200,
    );
  }

  List<ShopDiscoveryShop> _parseShopListPayload(dynamic payload) {
    final List<dynamic> rawList;

    if (payload is List) {
      rawList = payload;
    } else if (payload is Map<String, dynamic> && payload['results'] is List) {
      rawList = payload['results'] as List<dynamic>;
    } else {
      rawList = const <dynamic>[];
    }

    return rawList
        .whereType<Map>()
        .map(
          (item) => ShopDiscoveryShop.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }
}
