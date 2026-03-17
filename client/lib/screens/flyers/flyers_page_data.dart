part of '../flyers_page.dart';

extension _FlyersPageData on _FlyersPageState {
  List<Flyer> _filteredFlyers(List<Flyer> sourceFlyers) {
    var filtered = List<Flyer>.from(sourceFlyers);

    final selectedCategory = _selectedCategory;
    if (selectedCategory != null) {
      filtered = filtered
          .where((flyer) => flyer.category == selectedCategory)
          .toList(growable: false);
    }

    if (_selectedType != null) {
      filtered = filtered
          .where((flyer) => flyer.fileType == _selectedType)
          .toList(growable: false);
    }

    switch (_selectedSort) {
      case 'Plus récent':
        filtered.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));
        break;
      case 'Plus proche':
        filtered.sort((a, b) => _getDistance(a).compareTo(_getDistance(b)));
        break;
      case 'A-Z':
        filtered.sort((a, b) => a.storeName.compareTo(b.storeName));
        break;
      default:
        break;
    }

    return filtered;
  }
}
