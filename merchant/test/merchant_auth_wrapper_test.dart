import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localboost_merchant/main.dart' show MerchantAuthWrapper;
import 'package:localboost_merchant/screens/auth/merchant_auth_screen.dart';
import 'package:localboost_merchant/screens/merchant_main_screen.dart';
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class _TestAuthProvider extends AuthProvider {
  _TestAuthProvider(this._authenticated, this._user);

  final bool _authenticated;
  final User? _user;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  User? get user => _user;
}

User _buildUser(UserRole role) {
  return User(
    id: 'merchant-test-user',
    email: 'merchant@test.com',
    name: 'Merchant Tester',
    role: role,
    createdAt: DateTime(2026),
  );
}

void main() {
  testWidgets('MerchantAuthWrapper routes by authentication state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.shrink(),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    const wrapper = MerchantAuthWrapper();
    final built = wrapper.build(context);

    expect(built, isA<Consumer<AuthProvider>>());

    final consumer = built as Consumer<AuthProvider>;
    final authenticatedChild =
        consumer.builder(
          context,
          _TestAuthProvider(true, _buildUser(UserRole.merchant)),
          null,
        );
    final unauthenticatedChild =
        consumer.builder(context, _TestAuthProvider(false, null), null);

    expect(authenticatedChild, isA<MerchantMainScreen>());
    expect(unauthenticatedChild, isA<MerchantAuthScreen>());
  });

  testWidgets('MerchantAuthWrapper blocks customer role from merchant shell', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.shrink(),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    const wrapper = MerchantAuthWrapper();
    final built = wrapper.build(context);

    expect(built, isA<Consumer<AuthProvider>>());

    final consumer = built as Consumer<AuthProvider>;
    final customerChild = consumer.builder(
      context,
      _TestAuthProvider(true, _buildUser(UserRole.customer)),
      null,
    );

    expect(customerChild, isA<MerchantAuthScreen>());
  });
}
