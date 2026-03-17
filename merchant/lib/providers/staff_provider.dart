import 'package:flutter/foundation.dart';
import 'package:localboost_merchant/models/staff_member.dart';

/// Manages in-session staff members (scanner-only access).
///
/// Staff data is kept in memory for the session.
/// The merchant (owner) creates PIN-protected staff accounts
/// so employees can access the scanner without full merchant access.
class StaffProvider with ChangeNotifier {
  final List<StaffMember> _staff = [];

  List<StaffMember> get staff => List.unmodifiable(_staff);

  void addStaff({required String name, required String pin}) {
    final member = StaffMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      pin: pin,
    );
    _staff.add(member);
    notifyListeners();
  }

  void removeStaff(String id) {
    _staff.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// Returns the staff member if the PIN matches any registered staff.
  StaffMember? validatePin(String pin) {
    try {
      return _staff.firstWhere((s) => s.pin == pin);
    } catch (_) {
      return null;
    }
  }
}
