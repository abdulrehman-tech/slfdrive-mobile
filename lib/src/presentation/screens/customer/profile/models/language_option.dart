import 'package:flutter/material.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;
  const LanguageOption(this.code, this.name, this.nativeName, this.locale);
}
