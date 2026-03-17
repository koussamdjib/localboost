import 'package:flutter/foundation.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/providers/deal/deal_mapper.dart';
import 'package:localboost_merchant/services/merchant_deals_service.dart';

/// Provider for managing merchant deals
class DealProvider with ChangeNotifier {
  final MerchantDealsService _dealsService = MerchantDealsService();

  List<Deal> _deals = <Deal>[];
  bool _isLoading = false;
  String? _error;

  List<Deal> get deals => _deals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Deal> get activeDeals =>
      _deals.where((d) => d.status == DealStatus.active).toList();
  List<Deal> get draftDeals =>
      _deals.where((d) => d.status == DealStatus.draft).toList();
  List<Deal> get expiredDeals => _deals.where((d) => d.isExpired).toList();

  /// Load deals for a specific shop
  Future<void> loadDeals(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedShopId = int.tryParse(shopId);
      if (parsedShopId == null) {
        _deals = <Deal>[];
        _error = 'Identifiant de boutique invalide.';
        return;
      }

      final rawDeals = await _dealsService.listDeals(parsedShopId);
      _deals = rawDeals.map(DealMapper.fromApi).toList(growable: false);
    } catch (e) {
      debugPrint('Error loading deals: $e');
      _deals = <Deal>[];
      _error = 'Erreur lors du chargement des offres.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new deal
  Future<bool> createDeal(Deal deal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shopId = int.tryParse(deal.shopId);
      if (shopId == null) {
        _error = 'Identifiant de boutique invalide.';
        return false;
      }

      final rawDeal = await _dealsService.createDeal(
        shopId: shopId,
        payload: DealMapper.toPayload(deal),
      );
      final createdDeal = DealMapper.fromApi(rawDeal);
      _upsertDeal(createdDeal);
      return true;
    } catch (e) {
      debugPrint('Error creating deal: $e');
      _error = 'Erreur lors de la creation de l\'offre.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Deal?> loadDealById(String dealId) async {
    final parsedDealId = int.tryParse(dealId);
    if (parsedDealId == null) {
      _error = 'Identifiant d\'offre invalide.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawDeal = await _dealsService.getDeal(parsedDealId);
      final normalizedDeal = DealMapper.fromApi(rawDeal);
      _upsertDeal(normalizedDeal);
      return normalizedDeal;
    } catch (e) {
      debugPrint('Error loading deal detail: $e');
      _error = 'Erreur lors du chargement de l\'offre.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Deal?> recordDealView(String dealId) async {
    return _recordDealMetric(
      dealId: dealId,
      request: (parsedDealId) => _dealsService.trackDealView(parsedDealId),
      errorMessage: 'Erreur lors de l\'enregistrement de la vue.',
    );
  }

  Future<Deal?> recordDealShare(String dealId) async {
    return _recordDealMetric(
      dealId: dealId,
      request: (parsedDealId) => _dealsService.trackDealShare(parsedDealId),
      errorMessage: 'Erreur lors de l\'enregistrement du partage.',
    );
  }

  /// Update an existing deal
  Future<bool> updateDeal(String dealId, Deal updatedDeal) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedDealId = int.tryParse(dealId);
      if (parsedDealId == null) {
        _error = 'Identifiant d\'offre invalide.';
        return false;
      }

      final rawDeal = await _dealsService.updateDeal(
        dealId: parsedDealId,
        payload: DealMapper.toPayload(updatedDeal),
      );
      final normalizedDeal = DealMapper.fromApi(rawDeal);
      _upsertDeal(normalizedDeal);
      return true;
    } catch (e) {
      debugPrint('Error updating deal: $e');
      _error = 'Erreur lors de la mise a jour de l\'offre.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a deal
  Future<bool> deleteDeal(String dealId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedDealId = int.tryParse(dealId);
      if (parsedDealId == null) {
        _error = 'Identifiant d\'offre invalide.';
        return false;
      }

      await _dealsService.deleteDeal(parsedDealId);
      _deals.removeWhere((d) => d.id == dealId);
      return true;
    } catch (e) {
      debugPrint('Error deleting deal: $e');
      _error = 'Erreur lors de l\'archivage de l\'offre.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate a draft deal
  Future<bool> activateDeal(String dealId) async {
    try {
      final deal = _deals.firstWhere((d) => d.id == dealId);
      return await updateDeal(dealId, deal.copyWith(status: DealStatus.active));
    } catch (e) {
      debugPrint('Error activating deal: $e');
      _error = 'Impossible d\'activer cette offre.';
      notifyListeners();
      return false;
    }
  }

  void clearDeals() {
    _deals = <Deal>[];
    _error = null;
    notifyListeners();
  }

  Future<Deal?> _recordDealMetric({
    required String dealId,
    required Future<Map<String, dynamic>> Function(int parsedDealId) request,
    required String errorMessage,
  }) async {
    final parsedDealId = int.tryParse(dealId);
    if (parsedDealId == null) {
      _error = 'Identifiant d\'offre invalide.';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawDeal = await request(parsedDealId);
      final normalizedDeal = DealMapper.fromApi(rawDeal);
      _upsertDeal(normalizedDeal);
      return normalizedDeal;
    } catch (e) {
      debugPrint('Error recording deal metric: $e');
      _error = errorMessage;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _upsertDeal(Deal deal) {
    final index = _deals.indexWhere((item) => item.id == deal.id);
    if (index == -1) {
      _deals = <Deal>[deal, ..._deals];
      return;
    }

    _deals = _deals
        .asMap()
        .entries
        .map((entry) => entry.key == index ? deal : entry.value)
        .toList(growable: false);
  }
}