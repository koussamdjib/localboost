import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/locale_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/services/enrollment_service.dart';
import 'package:localboost_merchant/providers/shop_provider.dart';
import 'package:localboost_merchant/providers/flyer_provider.dart';
import 'package:localboost_merchant/providers/deal_provider.dart';
import 'package:localboost_merchant/providers/loyalty_provider.dart';
import 'package:localboost_merchant/providers/staff_provider.dart';
import 'package:localboost_merchant/screens/auth/merchant_auth_screen.dart';
import 'package:localboost_merchant/screens/merchant_main_screen.dart';
import 'package:localboost_merchant/services/connectivity_service.dart';
import 'package:localboost_merchant/services/offline_queue_service.dart';
import 'package:localboost_merchant/services/offline_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr', null);

  // Start offline sync service — drains queued stamps when connectivity resumes.
  final offlineSync = OfflineSyncService(
    enrollmentService: EnrollmentService(),
    queueService: OfflineQueueService(),
    connectivityService: ConnectivityService(),
  );
  offlineSync.start();

  runApp(const LocalBoostMerchantApp());
}

class LocalBoostMerchantApp extends StatelessWidget {
  const LocalBoostMerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Centralized provider registration for merchant app architecture.
        ChangeNotifierProvider(create: (_) => DealProvider()),
        ChangeNotifierProvider(create: (_) => LoyaltyProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => FlyerProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),

        ChangeNotifierProvider(create: (_) => AuthProvider()..initializeAuth()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) => MaterialApp(
          title: 'LocalBoost Merchant',
          debugShowCheckedModeBanner: false,
          locale: localeProvider.locale,
          supportedLocales: const [
            Locale('fr'),
            Locale('en'),
            Locale('ar'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryGreen,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.white,
          ),
          home: const MerchantAuthWrapper(),
        ),
      ),
    );
  }
}

class MerchantAuthWrapper extends StatelessWidget {
  const MerchantAuthWrapper({super.key});

  void _rejectInvalidRole(BuildContext context, AuthProvider authProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) {
        return;
      }
      if (!authProvider.isAuthenticated ||
          authProvider.user?.role == UserRole.merchant) {
        return;
      }

      await authProvider.logout();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce compte client doit utiliser l\'application client.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const MerchantAuthScreen();
        }

        if (authProvider.user?.role != UserRole.merchant) {
          _rejectInvalidRole(context, authProvider);
          return const MerchantAuthScreen();
        }

        return const MerchantMainScreen();
      },
    );
  }
}
