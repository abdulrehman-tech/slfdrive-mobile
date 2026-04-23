import 'package:flutter/material.dart';
import '../data/language_data.dart';
import '../models/language_option.dart';

class LanguageSelectionProvider extends ChangeNotifier {
  LanguageSelectionProvider() {
    _filteredLanguages = LanguageData.all;
    searchController.addListener(_filterLanguages);
  }

  final TextEditingController searchController = TextEditingController();

  String? _selectedLanguageCode;
  String? get selectedLanguageCode => _selectedLanguageCode;

  bool _isApplying = false;
  bool get isApplying => _isApplying;

  List<LanguageOption> _filteredLanguages = const [];
  List<LanguageOption> get filteredLanguages => _filteredLanguages;

  LanguageOption? get selectedLanguage {
    if (_selectedLanguageCode == null) return null;
    for (final lang in LanguageData.all) {
      if (lang.code == _selectedLanguageCode) return lang;
    }
    return null;
  }

  bool get hasSelection => _selectedLanguageCode != null;

  void _filterLanguages() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredLanguages = LanguageData.all;
    } else {
      _filteredLanguages = LanguageData.all
          .where((lang) => lang.name.toLowerCase().contains(query))
          .toList();
    }
    notifyListeners();
  }

  void selectLanguage(LanguageOption language) {
    if (_selectedLanguageCode == language.code) return;
    _selectedLanguageCode = language.code;
    notifyListeners();
  }

  void setApplying(bool value) {
    if (_isApplying == value) return;
    _isApplying = value;
    notifyListeners();
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_filterLanguages)
      ..dispose();
    super.dispose();
  }
}
