import 'package:flutter/material.dart';
import '../models/language_option.dart';

class LanguageData {
  const LanguageData._();

  static const List<LanguageOption> all = [
    LanguageOption(code: 'en', name: 'English', flag: '🇺🇸', locale: Locale('en', 'US')),
    LanguageOption(code: 'ar', name: 'العربية', flag: '🇴🇲', locale: Locale('ar', 'AE')),
    LanguageOption(code: 'hi', name: 'हिन्दी', flag: '🇮🇳', locale: Locale('hi', 'IN')),
    LanguageOption(code: 'ur', name: 'اردو', flag: '🇵🇰', locale: Locale('ur', 'PK')),
    LanguageOption(code: 'de', name: 'Deutsch', flag: '🇩🇪', locale: Locale('de', 'DE')),
    LanguageOption(code: 'es', name: 'Español', flag: '🇪🇸', locale: Locale('es', 'ES')),
    LanguageOption(code: 'ru', name: 'Русский', flag: '🇷🇺', locale: Locale('ru', 'RU')),
  ];
}
