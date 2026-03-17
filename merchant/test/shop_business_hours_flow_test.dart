import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:localboost_merchant/models/business_hours.dart';
import 'package:localboost_merchant/models/merchant_account.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/screens/profile/merchant_profile_screen.dart';
import 'package:localboost_merchant/screens/shop/edit_business_hours_screen.dart';
import 'package:localboost_merchant/screens/shop/shop_profile_screen.dart';
import 'package:localboost_shared/models/search_filter.dart' show ShopCategory;
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/providers/auth_provider.dart';

class _TestShopProvider extends ShopProvider {
  _TestShopProvider({MerchantAccount? account}) : _account = account;

  MerchantAccount? _account;
  int updateBusinessHoursCallCount = 0;
  BusinessHours? lastUpdatedHours;

  @override
  MerchantAccount? get merchantAccount => _account;

  void setAccount(MerchantAccount? account) {
    _account = account;
    notifyListeners();
  }

  @override
  Future<bool> updateBusinessHours(BusinessHours hours) async {
    updateBusinessHoursCallCount += 1;
    lastUpdatedHours = hours;

    if (_account != null) {
      _account = _account!.copyWith(businessHours: hours);
    }

    notifyListeners();
    return true;
  }
}

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider(this._user);

  final User _user;

  @override
  User? get user => _user;

  @override
  bool get isAuthenticated => true;
}

MerchantAccount _buildMerchantAccount() {
  return MerchantAccount(
    id: 'shop-1',
    userId: 'merchant-user-1',
    businessName: 'Shop One',
    description: 'Boutique test',
    category: ShopCategory.other,
    address: 'Rue principale, Djibouti',
    latitude: 11.588,
    longitude: 43.145,
    phone: '+25377000000',
    logoUrl: null,
    coverImageUrl: null,
    businessHours: BusinessHours.defaultHours(),
    createdAt: DateTime(2026, 3, 12),
    isVerified: true,
    isActive: true,
  );
}

User _buildMerchantUser() {
  return User(
    id: 'merchant-user-1',
    email: 'merchant@test.com',
    name: 'Merchant Tester',
    role: UserRole.merchant,
    createdAt: DateTime(2026, 3, 12),
  );
}

Widget _buildShopProfileApp(_TestShopProvider shopProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ShopProvider>.value(value: shopProvider),
    ],
    child: const MaterialApp(
      home: ShopProfileScreen(),
    ),
  );
}

Widget _buildHoursEditorApp(_TestShopProvider shopProvider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<ShopProvider>.value(value: shopProvider),
    ],
    child: MaterialApp(
      home: EditBusinessHoursScreen(
        initialHours: BusinessHours.defaultHours(),
      ),
    ),
  );
}

Widget _buildMerchantProfileApp({
  required _TestAuthProvider authProvider,
  required _TestShopProvider shopProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<ShopProvider>.value(value: shopProvider),
    ],
    child: const MaterialApp(
      home: MerchantProfileScreen(),
    ),
  );
}

void main() {
  testWidgets('Shop profile edit button opens business hours editor', (
    tester,
  ) async {
    final shopProvider = _TestShopProvider(account: _buildMerchantAccount());

    await tester.pumpWidget(_buildShopProfileApp(shopProvider));
    await tester.pumpAndSettle();

    expect(find.byType(ShopProfileScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byType(EditBusinessHoursScreen), findsOneWidget);
    expect(find.text('Modifier les horaires'), findsOneWidget);
  });

  testWidgets('Business hours editor save triggers provider update', (
    tester,
  ) async {
    final shopProvider = _TestShopProvider(account: _buildMerchantAccount());

    await tester.pumpWidget(_buildHoursEditorApp(shopProvider));
    await tester.pumpAndSettle();

    expect(find.byType(EditBusinessHoursScreen), findsOneWidget);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(shopProvider.updateBusinessHoursCallCount, 1);
    expect(shopProvider.lastUpdatedHours, isNotNull);
  });

  testWidgets('Merchant profile exposes Ma boutique navigation', (
    tester,
  ) async {
    final authProvider = _TestAuthProvider(_buildMerchantUser());
    final shopProvider = _TestShopProvider(account: _buildMerchantAccount());

    await tester.pumpWidget(
      _buildMerchantProfileApp(
        authProvider: authProvider,
        shopProvider: shopProvider,
      ),
    );
    await tester.pumpAndSettle();

    final boutiqueTile = find.widgetWithText(ListTile, 'Ma boutique');
    expect(boutiqueTile, findsOneWidget);

    await tester.ensureVisible(boutiqueTile);
    await tester.tap(boutiqueTile);
    await tester.pumpAndSettle();

    expect(find.byType(ShopProfileScreen), findsOneWidget);
  });
}
