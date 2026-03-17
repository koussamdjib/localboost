import 'dart:typed_data';

import 'package:dio/dio.dart' show FormData, MultipartFile, Options;
import 'package:localboost_merchant/models/merchant_shop.dart';
import 'package:localboost_shared/services/api/api_client.dart';

class MerchantShopsService {
  final ApiClient _client = ApiClient.instance;

  Future<List<MerchantShop>> listShops() async {
    final response = await _client.get('merchant/shops/');
    final data = response.data;
    final items = <dynamic>[];

    if (data is List) {
      items.addAll(data);
    } else if (data is Map && data['results'] is List) {
      items.addAll(data['results'] as List);
    }

    return items
        .whereType<Map>()
        .map((item) => MerchantShop.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<MerchantShop> createShop(
    Map<String, dynamic> payload, {
    Uint8List? logoBytes,
    String? logoFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final hasFiles = logoBytes != null || coverBytes != null;
    final dynamic response;
    if (hasFiles) {
      final formData = _buildFormData(
        payload,
        logoBytes: logoBytes,
        logoFileName: logoFileName,
        coverBytes: coverBytes,
        coverFileName: coverFileName,
      );
      response = await _client.upload<dynamic>(
        'merchant/shops/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      response = await _client.post('merchant/shops/', data: payload);
    }
    return MerchantShop.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<MerchantShop> updateShop(
    int shopId,
    Map<String, dynamic> payload, {
    Uint8List? logoBytes,
    String? logoFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) async {
    final hasFiles = logoBytes != null || coverBytes != null;
    final dynamic response;
    if (hasFiles) {
      final formData = _buildFormData(
        payload,
        logoBytes: logoBytes,
        logoFileName: logoFileName,
        coverBytes: coverBytes,
        coverFileName: coverFileName,
      );
      response = await _client.put<dynamic>(
        'merchant/shops/$shopId/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } else {
      response = await _client.put('merchant/shops/$shopId/', data: payload);
    }
    return MerchantShop.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<MerchantShop> updateShopPartial(
    int shopId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.patch('merchant/shops/$shopId/', data: payload);
    return MerchantShop.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deleteShop(int shopId) async {
    await _client.delete('merchant/shops/$shopId/');
  }

  FormData _buildFormData(
    Map<String, dynamic> payload, {
    Uint8List? logoBytes,
    String? logoFileName,
    Uint8List? coverBytes,
    String? coverFileName,
  }) {
    final formData = FormData();

    payload.forEach((key, value) {
      if (value == null) return;
      // Skip string fields overridden by a file upload
      if (key == 'logo' && logoBytes != null) return;
      if (key == 'cover_image' && coverBytes != null) return;
      formData.fields.add(MapEntry(key, value.toString()));
    });

    if (logoBytes != null) {
      formData.files.add(MapEntry(
        'logo',
        MultipartFile.fromBytes(logoBytes, filename: logoFileName ?? 'logo'),
      ));
    }

    if (coverBytes != null) {
      formData.files.add(MapEntry(
        'cover_image',
        MultipartFile.fromBytes(coverBytes, filename: coverFileName ?? 'cover'),
      ));
    }

    return formData;
  }
}
