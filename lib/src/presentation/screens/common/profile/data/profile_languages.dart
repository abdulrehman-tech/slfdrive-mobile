import 'package:flutter/material.dart';

/// A selectable app language: backend [code], English [name], [nativeName] and
/// the easy_localization [locale] it maps to.
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const LanguageOption(this.code, this.name, this.nativeName, this.locale);
}

/// All app languages offered in the profile language picker — kept in sync with
/// `supportedLocales` in `main.dart`.
const kProfileLanguages = <LanguageOption>[
  LanguageOption('en', 'English', 'English', Locale('en', 'US')),
  LanguageOption('ar', 'Arabic', 'العربية', Locale('ar', 'AE')),
  LanguageOption('hi', 'Hindi', 'हिन्दी', Locale('hi', 'IN')),
  LanguageOption('ur', 'Urdu', 'اردو', Locale('ur', 'PK')),
  LanguageOption('de', 'German', 'Deutsch', Locale('de', 'DE')),
  LanguageOption('es', 'Spanish', 'Español', Locale('es', 'ES')),
  LanguageOption('ru', 'Russian', 'Русский', Locale('ru', 'RU')),
];
