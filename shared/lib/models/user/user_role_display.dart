part of '../user.dart';

extension UserRoleDisplay on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Client';
      case UserRole.merchant:
        return 'Commerçant';
    }
  }
}
