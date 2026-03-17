import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localboost_client/main.dart' show AuthWrapper;
import 'package:localboost_client/screens/auth/client_auth_screen.dart';
import 'package:localboost_client/screens/main_screen.dart';
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
    id: 'test-user',
    email: 'test@example.com',
    name: 'Test User',
    role: role,
    createdAt: DateTime(2026),
  );
}

void main() {
  testWidgets('AuthWrapper routes by authentication state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.shrink(),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    const wrapper = AuthWrapper();
    final built = wrapper.build(context);

    expect(built, isA<Consumer<AuthProvider>>());

    final consumer = built as Consumer<AuthProvider>;
    final authenticatedChild =
        consumer.builder(
          context,
          _TestAuthProvider(true, _buildUser(UserRole.customer)),
          null,
        );
    final unauthenticatedChild =
        consumer.builder(context, _TestAuthProvider(false, null), null);

    expect(authenticatedChild, isA<MainScreen>());
    expect(unauthenticatedChild, isA<ClientAuthScreen>());
  });

  testWidgets('AuthWrapper blocks merchant role from client shell', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox.shrink(),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    const wrapper = AuthWrapper();
    final built = wrapper.build(context);

    expect(built, isA<Consumer<AuthProvider>>());

    final consumer = built as Consumer<AuthProvider>;
    final merchantChild = consumer.builder(
      context,
      _TestAuthProvider(true, _buildUser(UserRole.merchant)),
      null,
    );

    expect(merchantChild, isA<ClientAuthScreen>());
  });
}
