import 'package:flutter/foundation.dart';

import 'package:localboost_shared/models/enrollment.dart';
import 'package:localboost_shared/services/enrollment_service.dart';

part 'enrollment/enrollment_provider_getters.dart';
part 'enrollment/enrollment_provider_account_actions.dart';
part 'enrollment/enrollment_provider_rewards.dart';

class EnrollmentProvider extends ChangeNotifier {
  final EnrollmentService _enrollmentService = EnrollmentService();

  List<Enrollment> _enrollments = [];
  bool _isLoading = false;
  String? _error;

  List<Enrollment> get enrollments => _enrollments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _notifyStateChanged() {
    notifyListeners();
  }
}
