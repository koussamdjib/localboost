import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:localboost_shared/models/search_filter.dart';

class SearchProvider extends ChangeNotifier {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  List<SearchHistoryEntry> _searchHistory = [];
  SearchFilter _currentFilter = const SearchFilter();

  List<SearchHistoryEntry> get searchHistory => _searchHistory;
  SearchFilter get currentFilter => _currentFilter;

  Future<void> initialize() async {
    await _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);

      if (historyJson != null) {
        final List<dynamic> decoded = jsonDecode(historyJson);
        _searchHistory = decoded
            .map((item) =>
                SearchHistoryEntry.fromJson(item as Map<String, dynamic>))
            .toList();

        _searchHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading search history: $e');
      }
    }
  }

  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _searchHistory.map((entry) => entry.toJson()).toList(),
      );
      await prefs.setString(_historyKey, encoded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving search history: $e');
      }
    }
  }

  Future<void> addToHistory(String query) async {
    if (query.trim().isEmpty) return;

    _searchHistory.removeWhere(
      (entry) => entry.query.toLowerCase() == query.toLowerCase(),
    );

    _searchHistory.insert(
      0,
      SearchHistoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        query: query.trim(),
        timestamp: DateTime.now(),
      ),
    );

    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
    }

    await _saveSearchHistory();
    notifyListeners();
  }

  Future<void> removeFromHistory(String id) async {
    _searchHistory.removeWhere((entry) => entry.id == id);
    await _saveSearchHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _searchHistory.clear();
    await _saveSearchHistory();
    notifyListeners();
  }

  void updateFilter(SearchFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void updateQuery(String query) {
    _currentFilter = _currentFilter.copyWith(query: query);
    notifyListeners();
  }

  void updateCategory(ShopCategory category) {
    _currentFilter = _currentFilter.copyWith(category: category);
    notifyListeners();
  }

  void updateOfferType(OfferType offerType) {
    _currentFilter = _currentFilter.copyWith(offerType: offerType);
    notifyListeners();
  }

  void updateDistance(DistanceRange distance) {
    _currentFilter = _currentFilter.copyWith(distance: distance);
    notifyListeners();
  }

  void updateSort(SortOption sortBy) {
    _currentFilter = _currentFilter.copyWith(sortBy: sortBy);
    notifyListeners();
  }

  void resetFilter() {
    _currentFilter = const SearchFilter();
    notifyListeners();
  }

  void resetAdvancedFilters() {
    _currentFilter = SearchFilter(
      query: _currentFilter.query,
      sortBy: _currentFilter.sortBy,
    );
    notifyListeners();
  }
}
