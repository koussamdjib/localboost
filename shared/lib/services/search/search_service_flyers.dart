part of '../search_service.dart';

Future<List<Flyer>> _searchFlyersAsyncImpl({
  required String query,
  ShopCategory? category,
  LatLng? userLocation,
}) async {
  try {
    final categoryValue =
        category == null || category == ShopCategory.all
            ? null
            : _categoryToApiValue(category);
    final results = await SearchService._flyerService.listFlyers(
      query: query,
      category: categoryValue,
    );

    return _sortFlyers(results, userLocation);
  } catch (_) {
    return const <Flyer>[];
  }
}

List<Flyer> _sortFlyers(List<Flyer> flyers, LatLng? userLocation) {
  final results = List<Flyer>.from(flyers);

  if (userLocation != null) {
    results.sort((a, b) {
      final distA = _calculateDistance(
        userLocation,
        LatLng(a.latitude, a.longitude),
      );
      final distB = _calculateDistance(
        userLocation,
        LatLng(b.latitude, b.longitude),
      );
      return distA.compareTo(distB);
    });
  } else {
    results.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
  }

  return results;
}

