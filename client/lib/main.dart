import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_client/screens/auth/client_auth_screen.dart';
import 'package:localboost_client/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/models/user.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/providers/locale_provider.dart';
import 'package:localboost_shared/providers/notification_provider.dart';
import 'package:localboost_shared/providers/search_provider.dart';
import 'package:localboost_shared/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();

  runApp(const LocalBoostClientApp());
}

class LocalBoostClientApp extends StatelessWidget {
  const LocalBoostClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuth(),
        ),
        ChangeNotifierProvider(
          create: (_) => EnrollmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) => MaterialApp(
          title: 'LocalBoost Client',
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
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          home: const ClientAuthWrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class ClientAuthWrapper extends StatelessWidget {
  const ClientAuthWrapper({super.key});

  void _rejectInvalidRole(BuildContext context, AuthProvider authProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!context.mounted) {
        return;
      }
      if (!authProvider.isAuthenticated ||
          authProvider.user?.role == UserRole.customer) {
        return;
      }

      await authProvider.logout();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce compte marchand doit utiliser l\'application marchand.'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show login screen if not authenticated
        if (!authProvider.isAuthenticated) {
          return const ClientAuthScreen();
        }

        if (authProvider.user?.role != UserRole.customer) {
          _rejectInvalidRole(context, authProvider);
          return const ClientAuthScreen();
        }

        // Customer app - always show main screen when authenticated
        return const MainScreen();
      },
    );
  }
}

/// Backward-compatible alias for test imports.
typedef AuthWrapper = ClientAuthWrapper;
