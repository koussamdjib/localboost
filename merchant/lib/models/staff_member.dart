/// A staff member with scanner-only access, identified by a PIN.
class StaffMember {
  final String id;
  final String name;
  final String pin; // 4-digit PIN

  const StaffMember({
    required this.id,
    required this.name,
    required this.pin,
  });
}
