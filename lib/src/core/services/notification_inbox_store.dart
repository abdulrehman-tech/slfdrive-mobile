import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/storage_keys.dart';

/// Disk layer for the locally-persisted notification inbox.
///
/// The backend has no notifications feed, so the in-app list is built entirely
/// from pushes this device received. Storage is [SharedPreferences] rather than
/// secure storage: the content is non-sensitive and the list grows, and the FCM
/// background isolate has to reach it too.
///
/// **Two keys, deliberately.** [StorageKeys.notifInbox] is the canonical list,
/// owned exclusively by the UI isolate. [StorageKeys.notifInboxPending] is an
/// append-only queue written exclusively by the background isolate and drained
/// by the UI isolate on resume. A single shared key would mean both isolates
/// doing read-modify-write against one value, which is a real lost-update race.
class NotificationInboxStore {
  /// Newest-first cap. Old entries fall off the end.
  static const int maxItems = 100;

  /// Each isolate holds its own in-memory SharedPreferences cache, so a value
  /// written by the other isolate is invisible until an explicit reload.
  static Future<SharedPreferences> _prefs({bool reload = false}) async {
    final p = await SharedPreferences.getInstance();
    if (reload) await p.reload();
    return p;
  }

  static List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.whereType<Map>().map(Map<String, dynamic>.from).toList();
    } catch (e) {
      debugPrint('[Push] Corrupt inbox cache, discarding: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> readInbox() async {
    final prefs = await _prefs();
    return _decode(prefs.getString(StorageKeys.notifInbox));
  }

  Future<void> writeInbox(List<Map<String, dynamic>> items) async {
    final prefs = await _prefs();
    final capped = items.length > maxItems ? items.sublist(0, maxItems) : items;
    await prefs.setString(StorageKeys.notifInbox, jsonEncode(capped));
  }

  /// Reads and clears the background queue in one step. Reloads first so items
  /// the background isolate wrote while this isolate was alive are visible.
  Future<List<Map<String, dynamic>>> drainPending() async {
    final prefs = await _prefs(reload: true);
    final pending = _decode(prefs.getString(StorageKeys.notifInboxPending));
    if (pending.isNotEmpty) {
      await prefs.remove(StorageKeys.notifInboxPending);
    }
    return pending;
  }

  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(StorageKeys.notifInbox);
    await prefs.remove(StorageKeys.notifInboxPending);
  }

  /// Background-isolate entry point. Static because the isolate has no access to
  /// `getIt` and cannot resolve an instance. Appends without touching the
  /// canonical list.
  static Future<void> appendPending(Map<String, dynamic> json) async {
    final prefs = await _prefs(reload: true);
    final pending = _decode(prefs.getString(StorageKeys.notifInboxPending))
      ..add(json);
    // Bound the queue too: a device left backgrounded for a long time should not
    // accumulate more than the inbox can hold anyway.
    final capped = pending.length > maxItems
        ? pending.sublist(pending.length - maxItems)
        : pending;
    await prefs.setString(StorageKeys.notifInboxPending, jsonEncode(capped));
  }
}
