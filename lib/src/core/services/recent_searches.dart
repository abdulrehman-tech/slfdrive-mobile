import 'package:shared_preferences/shared_preferences.dart';

/// The customer's last few search terms, kept on this device.
class RecentSearches {
  static const _key = 'recent_searches_v1';
  static const max = 8;

  Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? const [];
    } catch (_) {
      return const [];
    }
  }

  /// Moves [term] to the front (case-insensitive de-dupe) and returns the list.
  Future<List<String>> add(String term) async {
    final t = term.trim();
    if (t.length < 2) return load();
    final next = [t, ...(await load()).where((e) => e.toLowerCase() != t.toLowerCase())].take(max).toList();
    await _save(next);
    return next;
  }

  Future<List<String>> remove(String term) async {
    final next = (await load()).where((e) => e != term).toList();
    await _save(next);
    return next;
  }

  Future<void> clear() => _save(const []);

  Future<void> _save(List<String> terms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, terms);
    } catch (_) {
      // Best effort — recent searches are a convenience.
    }
  }
}
