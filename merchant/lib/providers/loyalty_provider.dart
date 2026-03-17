import 'package:flutter/foundation.dart';
import 'package:localboost_merchant/models/loyalty_program.dart';
import 'package:localboost_merchant/services/merchant_loyalty_service.dart';
import 'package:localboost_shared/services/api/api_exception.dart';

/// Provider for managing merchant loyalty programs
class LoyaltyProvider with ChangeNotifier {
  final MerchantLoyaltyService _loyaltyService = MerchantLoyaltyService();

  List<LoyaltyProgram> _programs = <LoyaltyProgram>[];
  bool _isLoading = false;
  String? _error;

  List<LoyaltyProgram> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LoyaltyProgram> get activePrograms =>
      _programs.where((p) => p.status == ProgramStatus.active).toList(growable: false);
  List<LoyaltyProgram> get draftPrograms =>
      _programs.where((p) => p.status == ProgramStatus.draft).toList(growable: false);
  /// Clear programs list (e.g. when no shop is selected).
  void clearPrograms() {
    _programs = <LoyaltyProgram>[];
    _error = null;
    notifyListeners();
  }

  /// Load programs for a specific shop
  Future<void> loadPrograms(String shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedShopId = int.tryParse(shopId);
      if (parsedShopId == null) {
        _programs = <LoyaltyProgram>[];
        _error = 'Identifiant de boutique invalide.';
        return;
      }

      final rawPrograms = await _loyaltyService.listPrograms(parsedShopId);
      _programs = rawPrograms.map(_programFromApi).toList(growable: false);
    } catch (e) {
      debugPrint('Error loading programs: $e');
      _programs = <LoyaltyProgram>[];
      _error = _toReadableError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new program
  Future<bool> createProgram(LoyaltyProgram program) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final shopId = int.tryParse(program.shopId);
      if (shopId == null) {
        _error = 'Identifiant de boutique invalide.';
        return false;
      }

      final rawProgram = await _loyaltyService.createProgram(
        shopId: shopId,
        payload: _programToApiPayload(program),
      );
      final createdProgram = _programFromApi(rawProgram);
      _upsertProgram(createdProgram);
      return true;
    } catch (e) {
      debugPrint('Error creating program: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing program
  Future<bool> updateProgram(
      String programId, LoyaltyProgram updatedProgram) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedProgramId = int.tryParse(programId);
      if (parsedProgramId == null) {
        _error = 'Identifiant de programme invalide.';
        return false;
      }

      final rawProgram = await _loyaltyService.updateProgram(
        programId: parsedProgramId,
        payload: _programToApiPayload(updatedProgram),
      );
      final normalizedProgram = _programFromApi(rawProgram);
      _upsertProgram(normalizedProgram);
      return true;
    } catch (e) {
      debugPrint('Error updating program: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a program
  Future<bool> deleteProgram(String programId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final parsedProgramId = int.tryParse(programId);
      if (parsedProgramId == null) {
        _error = 'Identifiant de programme invalide.';
        return false;
      }

      await _loyaltyService.deleteProgram(parsedProgramId);
      _programs = _programs
          .where((program) => program.id != programId)
          .toList(growable: false);
      return true;
    } catch (e) {
      debugPrint('Error deleting program: $e');
      _error = _toReadableError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Activate a draft program
  Future<bool> activateProgram(String programId) async {
    try {
      final program = _programs.firstWhere((p) => p.id == programId);
      return await updateProgram(
          programId, program.copyWith(status: ProgramStatus.active));
    } catch (e) {
      debugPrint('Error activating program: $e');
      return false;
    }
  }

  /// Pause an active program
  Future<bool> pauseProgram(String programId) async {
    try {
      final program = _programs.firstWhere((p) => p.id == programId);
      return await updateProgram(
          programId, program.copyWith(status: ProgramStatus.draft));
    } catch (e) {
      debugPrint('Error pausing program: $e');
      _error = 'Impossible de desactiver ce programme.';
      notifyListeners();
      return false;
    }
  }

  void clear() {
    _programs = <LoyaltyProgram>[];
    _error = null;
    notifyListeners();
  }

  void _upsertProgram(LoyaltyProgram program) {
    final index = _programs.indexWhere((item) => item.id == program.id);
    if (index == -1) {
      _programs = <LoyaltyProgram>[program, ..._programs];
      return;
    }

    _programs = _programs
        .asMap()
        .entries
        .map((entry) => entry.key == index ? program : entry.value)
        .toList(growable: false);
  }

  LoyaltyProgram _programFromApi(Map<String, dynamic> json) {
    final nowUtc = DateTime.now().toUtc();

    return LoyaltyProgram(
      id: _toStringValue(json['id']),
      shopId: _toStringValue(json['shop_id']),
      title: _toStringValue(json['name']),
      description: _toStringValue(json['description']),
      stampsRequired: _toIntValue(json['stamps_required']) ?? 10,
      rewardDescription: _toStringValue(json['reward_label']),
      imageUrl: null,
      termsAndConditions: '',
      validFrom: null,
      validUntil: null,
      status: (json['is_active'] as bool? ?? false)
          ? ProgramStatus.active
          : ProgramStatus.draft,
      maxEnrollments: null,
      enrollmentCount: _toIntValue(json['enrollment_count']) ?? 0,
      totalStampsGranted: _toIntValue(json['total_stamps_granted']) ?? 0,
      redemptionCount: _toIntValue(json['redemption_count']) ?? 0,
      activeMembers: _toIntValue(json['active_members']) ?? _toIntValue(json['enrollment_count']) ?? 0,
      createdAt: _parseDateTime(json['created_at'], fallback: nowUtc).toLocal(),
    );
  }

  Map<String, dynamic> _programToApiPayload(LoyaltyProgram program) {
    return <String, dynamic>{
      'name': program.title,
      'description': program.description,
      'stamps_required': program.stampsRequired,
      'reward_label': program.rewardDescription,
      'is_active': program.status == ProgramStatus.active,
    };
  }

  String _toReadableError(Object error) {
    if (error is ValidationException) {
      return error.allFieldErrors;
    }
    if (error is ApiException) {
      final fieldErrors = _extractFieldErrors(error.data);
      if (fieldErrors != null && fieldErrors.isNotEmpty) {
        return fieldErrors;
      }
      return error.message;
    }
    return 'Erreur lors de la gestion des programmes.';
  }

  String? _extractFieldErrors(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final messages = data.entries
        .where((entry) => entry.value is String || entry.value is List)
        .map((entry) {
          final value = entry.value;
          if (value is List) {
            return '${entry.key}: ${value.join(', ')}';
          }
          return '${entry.key}: $value';
        })
        .where((message) => message.trim().isNotEmpty)
        .toList(growable: false);

    if (messages.isEmpty) {
      return null;
    }

    return messages.join('\n');
  }

  DateTime _parseDateTime(dynamic rawValue, {required DateTime fallback}) {
    if (rawValue is String) {
      final parsed = DateTime.tryParse(rawValue);
      if (parsed != null) {
        return parsed.toUtc();
      }
    }
    return fallback;
  }

  int? _toIntValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  String _toStringValue(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }
}
