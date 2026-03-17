import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/services/base_service.dart';

class FlyerService extends BaseService {
  Future<List<Flyer>> listFlyers({
    String query = '',
    String? category,
    int? shopId,
  }) async {
    final response = await client.get(
      'flyers/',
      queryParameters: <String, dynamic>{
        if (query.trim().isNotEmpty) 'q': query.trim(),
        if (category != null && category.trim().isNotEmpty)
          'category': category.trim(),
        if (shopId != null) 'shop_id': shopId,
      },
    );

    return extractList(response.data)
        .map(Flyer.fromJson)
        .toList(growable: false);
  }
}
