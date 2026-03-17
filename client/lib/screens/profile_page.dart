import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localboost_client/screens/change_password_page.dart';
import 'package:localboost_client/screens/edit_profile_page.dart';
import 'package:localboost_client/screens/notification_settings_page.dart';
import 'package:localboost_client/screens/reward_history_page.dart';
import 'package:localboost_client/screens/transaction_history_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:localboost_shared/core/constants/app_colors.dart';
import 'package:localboost_shared/providers/auth_provider.dart';
import 'package:localboost_shared/providers/enrollment_provider.dart';
import 'package:localboost_shared/providers/locale_provider.dart';

part 'profile/profile_page_feedback.dart';
part 'profile/profile_page_header_stats.dart';
part 'profile/profile_page_user_section.dart';
part 'profile/profile_page_user_avatar.dart';
part 'profile/profile_page_settings_section.dart';
part 'profile/profile_page_settings_item.dart';
part 'profile/profile_page_language_dialog.dart';
part 'profile/profile_page_logout_dialog.dart';
part 'profile/profile_page_photo_options.dart';
part 'profile/profile_page_photo_actions.dart';
part 'profile/profile_page_delete_account_dialog.dart';
part 'profile/profile_page_delete_account_confirm.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _selectedLanguage = 'Français';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Keep subtitle in sync with the locale provider.
    _selectedLanguage = context.read<LocaleProvider>().displayName;
  }

  void _updateLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    // Actually change the app locale
    final langCode = LocaleProvider.langCodeFromDisplayName(language);
    context.read<LocaleProvider>().setLanguage(langCode);
  }

    int get _activeOffersCount => context
      .watch<AuthProvider>()
      .user
      ?.totalOffersJoined ??
      context
        .watch<EnrollmentProvider>()
        .enrollments
        .where((enrollment) => !enrollment.isRedeemed)
        .length;

    int get _totalStamps => context
      .watch<AuthProvider>()
      .user
      ?.totalStamps ??
      context
        .watch<EnrollmentProvider>()
        .enrollments
        .fold(0, (sum, enrollment) => sum + enrollment.stampsCollected);

    int get _rewardsEarned => context
      .watch<AuthProvider>()
      .user
      ?.totalRewardsRedeemed ??
      context
        .watch<EnrollmentProvider>()
        .enrollments
        .where((enrollment) => enrollment.isRedeemed)
        .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildUserSection(),
            const SizedBox(height: 16),
            _buildStatsSection(),
            const SizedBox(height: 16),
            _buildSettingsSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
