import 'package:localboost_shared/models/transaction.dart';
import 'package:localboost_shared/services/api/api_client.dart';

class TransactionHistoryService {
  final ApiClient _client = ApiClient.instance;

  Future<List<Transaction>> fetchCustomerTransactions() async {
    final response = await _client.get('transactions/');
    final payload = response.data;
    final rawItems = _extractListPayload(payload);

    return rawItems
        .whereType<Map>()
        .map(
          (item) => _parseTransaction(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList(growable: false);
  }

  List<dynamic> _extractListPayload(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'];
      if (results is List) {
        return results;
      }

      final data = payload['data'];
      if (data is List) {
        return data;
      }
    }

    return const <dynamic>[];
  }

  Transaction _parseTransaction(Map<String, dynamic> json) {
    final type = _mapTransactionType(json['type']?.toString());

    return Transaction(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      shopId: json['shop_id']?.toString() ?? '',
      shopName: json['shop_name']?.toString() ?? '',
      shopLogoUrl: json['shop_logo_url']?.toString() ?? '',
      type: type,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      stampsAdded: _toIntOrNull(json['stamps_added']),
      rewardValue: _toNullableString(json['reward_value']),
      merchantNote: _toNullableString(json['merchant_note']),
      location: _toNullableString(json['location']),
    );
  }

  TransactionType _mapTransactionType(String? value) {
    switch (value) {
      case 'stampCollected':
      case 'stamp_collected':
        return TransactionType.stampCollected;
      case 'rewardRedeemed':
      case 'reward_redeemed':
        return TransactionType.rewardRedeemed;
      case 'enrolled':
        return TransactionType.enrolled;
      case 'unenrolled':
        return TransactionType.unenrolled;
      default:
        return TransactionType.stampCollected;
    }
  }

  int? _toIntOrNull(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }
}
