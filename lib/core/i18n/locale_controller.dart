import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';

  final SharedPreferences _prefs;
  Locale? _locale;

  LocaleController(this._prefs) {
    final saved = _prefs.getString(_prefsKey);
    if (saved != null && saved.isNotEmpty) {
      _locale = Locale(saved);
    }
  }

  Locale? get locale => _locale;

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    if (locale == null) {
      await _prefs.remove(_prefsKey);
    } else {
      await _prefs.setString(_prefsKey, locale.languageCode);
    }
    notifyListeners();
  }

  Future<void> setLanguageCode(String code) => setLocale(Locale(code));

  bool isSelected(String code) => _locale?.languageCode == code;
}
