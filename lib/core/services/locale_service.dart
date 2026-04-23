import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('bn'));
  static const String _localeKey = 'app_locale_code';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_localeKey);
    if (code != null) {
      localeNotifier.value = Locale(code);
    }
  }

  Future<void> changeLocale(String languageCode) async {
    localeNotifier.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }
}
