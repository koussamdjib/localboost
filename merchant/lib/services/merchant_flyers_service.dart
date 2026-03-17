import 'dart:typed_data';

import 'package:localboost_shared/models/flyer.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:dio/dio.dart' show FormData, MultipartFile, Options;

class MerchantFlyersService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Flyer>> listFlyers(int shopId) async {
    final response = await _client.get('merchant/shops/$shopId/flyers/');
    return _extractList(response.data)
        .map(Flyer.fromJson)
        .toList(growable: false);
  }

  Future<Flyer> createFlyer({
    required int shopId,
    required Map<String, dynamic> payload,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final response = fileBytes != null
        ? await _createFlyerWithBytes(shopId, payload, fileBytes, fileName)
        : await _client.post(
            'merchant/shops/$shopId/flyers/',
            data: payload,
          );
    return Flyer.fromJson(_extractMap(response.data));
  }

  Future<Flyer> updateFlyer({
    required int flyerId,
    required Map<String, dynamic> payload,
    Uint8List? fileBytes,
    String? fileName,
    bool partial = true,
  }) async {
    final response = fileBytes != null
        ? await _updateFlyerWithBytes(flyerId, payload, fileBytes, fileName)
        : partial
            ? await _client.patch('merchant/flyers/$flyerId/', data: payload)
            : await _client.put('merchant/flyers/$flyerId/', data: payload);
    return Flyer.fromJson(_extractMap(response.data));
  }

  Future<void> deleteFlyer(int flyerId) async {
    await _client.delete('merchant/flyers/$flyerId/');
  }

  Future<dynamic> _createFlyerWithBytes(
    int shopId,
    Map<String, dynamic> payload,
    Uint8List bytes,
    String? fileName,
  ) async {
    final formData = _buildFormDataFromBytes(payload, bytes, fileName);
    return _client.upload<dynamic>(
      'merchant/shops/$shopId/flyers/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  Future<dynamic> _updateFlyerWithBytes(
    int flyerId,
    Map<String, dynamic> payload,
    Uint8List bytes,
    String? fileName,
  ) async {
    final formData = _buildFormDataFromBytes(payload, bytes, fileName);
    return _client.patch<dynamic>(
      'merchant/flyers/$flyerId/',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  FormData _buildFormDataFromBytes(
    Map<String, dynamic> payload,
    Uint8List bytes,
    String? fileName,
  ) {
    final formData = FormData();

    payload.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    formData.files.add(
      MapEntry(
        'file',
        MultipartFile.fromBytes(bytes, filename: fileName ?? 'upload'),
      ),
    );

    return formData;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    final items = <dynamic>[];

    if (data is List) {
      items.addAll(data);
    } else if (data is Map && data['results'] is List) {
      items.addAll(data['results'] as List);
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw const FormatException('Expected object response from flyers API.');
  }
}
