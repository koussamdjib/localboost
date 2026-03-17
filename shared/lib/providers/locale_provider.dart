import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app locale. Defaults to French.
/// Persists the chosen language across restarts via shared_preferences.
///
/// Supported locales: fr, en, ar
class LocaleProvider with ChangeNotifier {
  static const _key = 'app_locale';

  Locale _locale = const Locale('fr');

  LocaleProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null && code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  /// Convenience: set locale from a language code string.
  void setLanguage(String langCode) {
    setLocale(Locale(langCode));
  }

  /// Returns the display name for the current locale.
  String get displayName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'fr':
      default:
        return 'Français';
    }
  }

  /// Maps a display name like "English" or "Français" to a language code.
  static String langCodeFromDisplayName(String name) {
    switch (name.toLowerCase()) {
      case 'english':
        return 'en';
      case 'عربية':
      case 'العربية':
        return 'ar';
      case 'français':
      default:
        return 'fr';
    }
  }
}
