import 'package:flutter_test/flutter_test.dart';
import 'package:localboost_shared/models/search_filter.dart';
import 'package:localboost_shared/models/user.dart';

void main() {
  group('shared models smoke tests', () {
    test('SearchFilter tracks active filters correctly', () {
      const base = SearchFilter();
      expect(base.hasActiveFilters, isFalse);
      expect(base.activeFilterCount, 0);

      final filtered = base.copyWith(
        category: ShopCategory.cafe,
        distance: DistanceRange.nearby,
      );

      expect(filtered.hasActiveFilters, isTrue);
      expect(filtered.activeFilterCount, 2);
    });

    test('User serializes and deserializes', () {
      final createdAt = DateTime.parse('2026-03-09T00:00:00Z');
      final lastLogin = DateTime.parse('2026-03-09T08:00:00Z');
      final user = User(
        id: 'user-1',
        email: 'jane@example.com',
        name: 'Jane Doe',
        createdAt: createdAt,
        lastLogin: lastLogin,
        lastLatitude: 11.55,
        lastLongitude: 43.14,
      );

      final restored = User.fromJson(user.toJson());
      expect(restored.email, user.email);
      expect(restored.role, UserRole.customer);
      expect(restored.initials, 'JD');
      expect(restored.lastLatitude, closeTo(11.55, 0.00001));
      expect(restored.lastLongitude, closeTo(43.14, 0.00001));
    });
  });
}
