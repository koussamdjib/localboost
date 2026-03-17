import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/services/api/api_exception.dart';
import 'package:localboost_merchant/services/merchant_flyers_service.dart';

/// Merchant flyer provider
class FlyerProvider with ChangeNotifier {
  final MerchantFlyersService _flyersService = MerchantFlyersService();

  List<Flyer> _flyers = <Flyer>[];
  bool _isLoading = false;
  String? _error;

  List<Flyer> get flyers => _flyers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Flyer> get draftFlyers =>
      _flyers
        .where(
        (f) =>
          f.status == FlyerStatus.draft ||
          f.status == FlyerStatus.paused,
        )
        .toList(growable: false);
  List<Flyer> get publishedFlyers =>
      _flyers
        .where((f) => f.status == FlyerStatus.published)
        .toList(growable: false);

  /// Load flyers for merchant
  Future<void> loadFlyers(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedShopId = int.tryParse(shopId);
      if (parsedShopId == null) {
        _flyers = <Flyer>[];
        _error = 'Identifiant de boutique invalide.';
        return;
      }

      _flyers = await _flyersService.listFlyers(parsedShopId);
    } catch (e) {
      debugPrint('Error loading flyers: $e');
      _flyers = <Flyer>[];
      _error = _toReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new flyer
  Future<bool> createFlyer(Flyer flyer,
      {Uint8List? fileBytes, String? fileName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shopId = int.tryParse(flyer.shopId ?? '');
      if (shopId == null) {
        _error = 'Identifiant de boutique invalide.';
        return false;
      }

      final createdFlyer = await _flyersService.createFlyer(
        shopId: shopId,
        payload: flyer.toMerchantPayload(),
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _upsertFlyer(createdFlyer);
      return true;
    } catch (e) {
      debugPrint('Error creating flyer: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update existing flyer
  Future<bool> updateFlyer(String id, Flyer updatedFlyer,
      {Uint8List? fileBytes, String? fileName}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final flyerId = int.tryParse(id);
      if (flyerId == null) {
        _error = 'Identifiant de circulaire invalide.';
        return false;
      }

      final normalizedFlyer = await _flyersService.updateFlyer(
        flyerId: flyerId,
        payload: updatedFlyer.toMerchantPayload(),
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _upsertFlyer(normalizedFlyer);
      return true;
    } catch (e) {
      debugPrint('Error updating flyer: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Publish flyer
  Future<bool> publishFlyer(String id) async {
    try {
      final flyer = _flyers.firstWhere((f) => f.id == id);
      return updateFlyer(
        id,
        flyer.copyWith(
          status: FlyerStatus.published,
          publishedDate: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Error publishing flyer: $e');
      _error = 'Impossible de publier cette circulaire.';
      notifyListeners();
      return false;
    }
  }

  /// Unpublish flyer
  Future<bool> unpublishFlyer(String id) async {
    try {
      final flyer = _flyers.firstWhere((f) => f.id == id);
      return updateFlyer(id, flyer.copyWith(status: FlyerStatus.paused));
    } catch (e) {
      debugPrint('Error unpublishing flyer: $e');
      _error = 'Impossible de suspendre cette circulaire.';
      notifyListeners();
      return false;
    }
  }

  /// Delete flyer
  Future<bool> deleteFlyer(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final flyerId = int.tryParse(id);
      if (flyerId == null) {
        _error = 'Identifiant de circulaire invalide.';
        return false;
      }

      await _flyersService.deleteFlyer(flyerId);
      _flyers = _flyers.where((flyer) => flyer.id != id).toList(growable: false);
      return true;
    } catch (e) {
      debugPrint('Error deleting flyer: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear flyers
  void clear() {
    _flyers = <Flyer>[];
    _error = null;
    notifyListeners();
  }

  void _upsertFlyer(Flyer flyer) {
    final index = _flyers.indexWhere((item) => item.id == flyer.id);
    if (index == -1) {
      _flyers = <Flyer>[flyer, ..._flyers];
      return;
    }

    _flyers = _flyers
        .asMap()
        .entries
        .map((entry) => entry.key == index ? flyer : entry.value)
        .toList(growable: false);
  }

  String _toReadableError(Object error) {
    if (error is ValidationException) {
      return error.allFieldErrors;
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'Erreur lors de la gestion des circulaires.';
  }
}
