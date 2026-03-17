import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localboost_merchant/models/deal.dart';
import 'package:localboost_merchant/models/merchant_shop.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/screens/deals/deals_list_screen.dart';
import 'package:provider/provider.dart';

class _TestDealProvider extends DealProvider {
  int loadDealsCallCount = 0;
  String? lastShopId;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  List<Deal> get deals => const <Deal>[];

  @override
  List<Deal> get activeDeals => const <Deal>[];

  @override
  List<Deal> get draftDeals => const <Deal>[];

  @override
  List<Deal> get expiredDeals => const <Deal>[];

  @override
  Future<void> loadDeals(String shopId) async {
    loadDealsCallCount += 1;
    lastShopId = shopId;
  }

  @override
  void clearDeals() {
    notifyListeners();
  }
}

class _TestShopProvider extends ShopProvider {
  MerchantShop? _currentShop;
  bool _hasShop = false;

  @override
  MerchantShop? get selectedShop => _currentShop;

  @override
  bool get hasShop => _hasShop;

  @override
  bool get isLoading => false;

  @override
  Future<void> loadMyShops() async {}

  void setShop(MerchantShop? shop, {required bool hasShop}) {
    _currentShop = shop;
    _hasShop = hasShop;
    notifyListeners();
  }
}

MerchantShop _buildShop({required int id, required String name}) {
  return MerchantShop(
    id: id,
    merchantProfile: 1,
    name: name,
    slug: 'shop-$id',
    description: '',
    category: '',
    phoneNumber: '',
    email: '',
    address: 'Rue principale',
    addressLine2: '',
    city: 'Djibouti',
    country: 'Djibouti',
    latitude: null,
    longitude: null,
    logo: '',
    coverImage: '',
    status: MerchantShopStatus.active,
    isActive: true,
    createdAt: DateTime(2026, 3, 11),
    updatedAt: DateTime(2026, 3, 11),
  );
}

Widget _buildTestApp({
  required _TestDealProvider dealProvider,
  required _TestShopProvider shopProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<DealProvider>.value(value: dealProvider),
      ChangeNotifierProvider<ShopProvider>.value(value: shopProvider),
    ],
    child: const MaterialApp(
      home: DealsListScreen(),
    ),
  );
}

Finder _findRichTextContaining(String value) {
  return find.byWidgetPredicate((widget) {
    if (widget is! RichText) {
      return false;
    }

    return widget.text.toPlainText().contains(value);
  });
}

void main() {
  testWidgets('Deals list shows explicit no-shop state when merchant has no shops', (
    tester,
  ) async {
    final dealProvider = _TestDealProvider();
    final shopProvider = _TestShopProvider()..setShop(null, hasShop: false);

    await tester.pumpWidget(
      _buildTestApp(dealProvider: dealProvider, shopProvider: shopProvider),
    );
    await tester.pump();

    expect(
      find.text('Créez d\'abord une boutique avant de gérer les offres.'),
      findsOneWidget,
    );
    expect(_findRichTextContaining('Boutique active'), findsNothing);
  });

  testWidgets('Deals list reloads when selected shop changes', (tester) async {
    final dealProvider = _TestDealProvider();
    final shopProvider = _TestShopProvider()
      ..setShop(_buildShop(id: 1, name: 'Shop One'), hasShop: true);

    await tester.pumpWidget(
      _buildTestApp(dealProvider: dealProvider, shopProvider: shopProvider),
    );
    await tester.pump();

    expect(dealProvider.loadDealsCallCount, 1);
    expect(dealProvider.lastShopId, '1');
    expect(_findRichTextContaining('Boutique active'), findsOneWidget);
    expect(_findRichTextContaining('Shop One'), findsOneWidget);

    shopProvider.setShop(_buildShop(id: 2, name: 'Shop Two'), hasShop: true);
    await tester.pump();
    await tester.pump();

    expect(dealProvider.loadDealsCallCount, 2);
    expect(dealProvider.lastShopId, '2');
    expect(_findRichTextContaining('Shop Two'), findsOneWidget);
  });
}
