import 'package:latlong2/latlong.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/models/loyalty_program_summary.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/models/shop_discovery_shop.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:localboost_shared/services/api/api_config.dart';
import 'package:localboost_shared/services/api/endpoints/shop_endpoints.dart';
import 'package:localboost_shared/services/flyer_service.dart';

part 'search/search_service_shop_search.dart';
part 'search/search_service_shop_sorting.dart';
part 'search/search_service_flyers.dart';
part 'search/search_service_deals.dart';

/// Service for searching and filtering shops, deals, and flyers
class SearchService {
  static final ApiClient _apiClient = ApiClient.instance;
  static final ShopEndpoints _shopEndpoints = ShopEndpoints();
  static final FlyerService _flyerService = FlyerService();

  /// Search shops with API integration.
  static Future<List<Shop>> searchShopsAsync({
    required SearchFilter filter,
    LatLng? userLocation,
  }) =>
      _searchShopsAsyncImpl(filter: filter, userLocation: userLocation);

  /// Search flyers with API integration.
  static Future<List<Flyer>> searchFlyersAsync({
    required String query,
    ShopCategory? category,
    LatLng? userLocation,
  }) =>
      _searchFlyersAsyncImpl(
        query: query,
        category: category,
        userLocation: userLocation,
      );

  /// Search public deals and map them into client cards.
  static Future<List<Shop>> searchDealsAsync({
    required SearchFilter filter,
    LatLng? userLocation,
    int? shopId,
  }) =>
      _searchDealsAsyncImpl(filter: filter, userLocation: userLocation, shopId: shopId);
}
