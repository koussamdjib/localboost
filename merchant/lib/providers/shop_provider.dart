import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:localboost_merchant/models/business_hours.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localboost_merchant/models/merchant_account.dart';
import 'package:localboost_merchant/models/merchant_shop.dart';
import 'package:localboost_merchant/services/merchant_shops_service.dart';
import 'package:localboost_shared/models/search_filter.dart' show ShopCategory;

/// Shop/merchant account provider
class ShopProvider with ChangeNotifier {
  final MerchantShopsService _shopsService = MerchantShopsService();

  List<MerchantShop> _shops = const <MerchantShop>[];
  MerchantShop? _selectedShop;
  MerchantAccount? _merchantAccount;
  bool _isLoading = false;
  String? _error;

  List<MerchantShop> get shops => _shops;
  MerchantShop? get selectedShop => _selectedShop;
  MerchantAccount? get merchantAccount => _merchantAccount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasShop => _shops.isNotEmpty;

  Future<void> loadMyShops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedShops = await _shopsService.listShops()
          .timeout(const Duration(seconds: 15));
      _shops = fetchedShops;

      if (_shops.isEmpty) {
        _selectedShop = null;
      } else {
        // Restore persisted shop selection, falling back to in-memory then first
        final prefs = await SharedPreferences.getInstance();
        final savedId = prefs.getInt('selected_shop_id');
        final inMemoryId = _selectedShop?.id;
        final preferredId = savedId ?? inMemoryId;
        if (preferredId != null) {
          _selectedShop = _firstWhereOrNull(_shops, (shop) => shop.id == preferredId);
        }
        _selectedShop ??= _shops.first;
      }

      _syncMerchantAccountFromSelected();
    } catch (e) {
      _error = 'Erreur lors du chargement des boutiques: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectShop(int shopId) async {
    final selected = _firstWhereOrNull(_shops, (shop) => shop.id == shopId);
    if (selected == null) {
      return;
    }

    _selectedShop = selected;
    _syncMerchantAccountFromSelected();
    notifyListeners();

    // Persist choice so it survives app restarts
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_shop_id', shopId);
  }

  Future<bool> createShop({
    required String name,
    String? slug,
    String description = '',
    String category = '',
    String phoneNumber = '',
    String email = '',
    required String address,
    String addressLine2 = '',
    String city = 'Djibouti',
    String country = 'Djibouti',
    double? latitude,
    double? longitude,
    String logo = '',
    String coverImage = '',
    MerchantShopStatus status = MerchantShopStatus.draft,
    Uint8List? logoBytes,
    String? logoFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdShop = await _shopsService.createShop({
        'name': name,
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        'description': description,
        'category': category,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
        'address_line_2': addressLine2,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'logo': logo,
        'cover_image': coverImage,
        'status': status.toApi(),
      },
        logoBytes: logoBytes,
        logoFileName: logoFileName,
        coverBytes: coverBytes,
        coverFileName: coverFileName,
      );

      _shops = [createdShop, ..._shops];
      _selectedShop = createdShop;
      _syncMerchantAccountFromSelected();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la creation de la boutique: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateShop({
    required int shopId,
    required String name,
    String? slug,
    String description = '',
    String category = '',
    String phoneNumber = '',
    String email = '',
    required String address,
    String addressLine2 = '',
    String city = 'Djibouti',
    String country = 'Djibouti',
    double? latitude,
    double? longitude,
    String logo = '',
    String coverImage = '',
    required MerchantShopStatus status,
    Uint8List? logoBytes,
    String? logoFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedShop = await _shopsService.updateShop(shopId, {
        'name': name,
        if (slug != null && slug.trim().isNotEmpty) 'slug': slug.trim(),
        'description': description,
        'category': category,
        'phone_number': phoneNumber,
        'email': email,
        'address': address,
        'address_line_2': addressLine2,
        'city': city,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'logo': logo,
        'cover_image': coverImage,
        'status': status.toApi(),
      },
        logoBytes: logoBytes,
        logoFileName: logoFileName,
        coverBytes: coverBytes,
        coverFileName: coverFileName,
      );

      _shops = _shops
          .map((shop) => shop.id == updatedShop.id ? updatedShop : shop)
          .toList(growable: false);

      if (_selectedShop?.id == updatedShop.id) {
        _selectedShop = updatedShop;
      }

      _syncMerchantAccountFromSelected();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise a jour: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteShop(int shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _shopsService.deleteShop(shopId);
      _shops = _shops.where((shop) => shop.id != shopId).toList(growable: false);

      if (_selectedShop?.id == shopId) {
        _selectedShop = _shops.isNotEmpty ? _shops.first : null;
      }

      _syncMerchantAccountFromSelected();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update business hours
  Future<bool> updateBusinessHours(BusinessHours hours) async {
    final selected = _selectedShop;
    if (selected == null) {
      _error = 'Aucune boutique sélectionnée.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedShop = await _shopsService.updateShopPartial(
        selected.id,
        {'business_hours': hours.toJson()},
      );

      _shops = _shops
          .map((shop) => shop.id == updatedShop.id ? updatedShop : shop)
          .toList(growable: false);

      if (_selectedShop?.id == updatedShop.id) {
        _selectedShop = updatedShop;
      }

      _syncMerchantAccountFromSelected();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear shop data
  void clear() {
    _shops = const <MerchantShop>[];
    _selectedShop = null;
    _merchantAccount = null;
    _error = null;
    notifyListeners();
  }

  void _syncMerchantAccountFromSelected() {
    final selected = _selectedShop;
    if (selected == null) {
      _merchantAccount = null;
      return;
    }

    _merchantAccount = MerchantAccount(
      id: selected.id.toString(),
      userId: selected.merchantProfile.toString(),
      businessName: selected.name,
      description: selected.description.isEmpty ? null : selected.description,
      category: _toShopCategory(selected.category),
      address: selected.address,
      latitude: selected.latitude ?? 0,
      longitude: selected.longitude ?? 0,
      phone: selected.phoneNumber.isEmpty ? null : selected.phoneNumber,
      logoUrl: selected.logo.isEmpty ? null : selected.logo,
      coverImageUrl: selected.coverImage.isEmpty ? null : selected.coverImage,
      businessHours: _toBusinessHours(selected.businessHours),
      createdAt: selected.createdAt,
      isVerified: selected.status == MerchantShopStatus.active,
      isActive: selected.isActive,
    );
  }

  BusinessHours _toBusinessHours(Map<String, dynamic>? rawBusinessHours) {
    if (rawBusinessHours == null || rawBusinessHours.isEmpty) {
      return BusinessHours.defaultHours();
    }

    try {
      return BusinessHours.fromJson(rawBusinessHours);
    } catch (_) {
      return BusinessHours.defaultHours();
    }
  }

  ShopCategory _toShopCategory(String rawCategory) {
    final normalized = rawCategory.trim().toLowerCase();
    for (final category in ShopCategory.values) {
      if (category.name == normalized) {
        return category;
      }
    }
    return ShopCategory.other;
  }

  MerchantShop? _firstWhereOrNull(
    Iterable<MerchantShop> values,
    bool Function(MerchantShop value) predicate,
  ) {
    for (final value in values) {
      if (predicate(value)) {
        return value;
      }
    }
    return null;
  }
}
