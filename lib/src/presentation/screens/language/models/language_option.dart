import 'package:flutter/material.dart';

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  final Locale locale;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.flag,
    required this.locale,
  });
}
