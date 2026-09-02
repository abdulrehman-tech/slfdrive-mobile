import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injection_container.dart';
import '../../../../../core/models/notification/push_payload.dart';
import '../../../../../core/services/notification_inbox_store.dart';
import '../../../../../core/utils/safe_notifier.dart';
import '../../../../routes/push_routes.dart';
import '../models/notif_item.dart';

/// The notification inbox, shared by both roles and by every screen.
///
/// Registered as an app-lifetime singleton (see `injection_container.dart`) and
/// exposed from the root `MultiProvider`, so the home-screen bell badge and the
/// notifications screen read the same state.
///
/// **Device-local by design.** The backend has no notifications feed, so this
/// list is assembled from pushes this device received and persisted via
/// [NotificationInboxStore]. Consequences worth knowing: read/unread state does
/// not sync, so a user with two devices sees two independent unread counts, and
/// clearing here clears nothing server-side. Revisit if a feed endpoint ships.
class NotificationsProvider extends ChangeNotifier with SafeNotifier {
  NotificationsProvider({NotificationInboxStore? store})
      : _store = store ?? getIt<NotificationInboxStore>();

  final NotificationInboxStore _store;

  final List<NotifItem> _items = [];
  int _tab = 0; // 0=All, 1=Bookings, 2=Promotions, 3=System

  static const List<NotifCategory?> categoryMap = [
    null,
    NotifCategory.booking,
    NotifCategory.promotion,
    NotifCategory.system,
  ];
  static const List<String> tabKeys = [
    'notif_tab_all',
    'notif_tab_bookings',
    'notif_tab_promos',
    'notif_tab_system',
  ];

  List<NotifItem> get items => _items;
  int get tab => _tab;

  List<NotifItem> get filtered {
    final cat = categoryMap[_tab];
    if (cat == null) return _items;
    return _items.where((n) => n.category == cat).toList();
  }

  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Null once the item has been deleted, cleared, or pushed past the cap while
  /// the detail screen was open.
  NotifItem? byId(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    return i == -1 ? null : _items[i];
  }

  int countForTab(int i) {
    if (i == 0) return _items.length;
    return _items.where((n) => n.category == categoryMap[i]).length;
  }

  void setTab(int i) {
    if (_tab == i) return;
    _tab = i;
    notifyListeners();
  }

  // ── persistence ──────────────────────────────────────────────────────────

  /// Hydrates from disk and folds in anything the background isolate queued
  /// while the app was dead. Called once from `main()`.
  Future<void> load() async {
    final stored = await _store.readInbox();
    _items
      ..clear()
      ..addAll(stored.map(NotifItem.fromJson));
    await drainBackgroundQueue(persist: false);
    _sortAndCap();
    await _persist();
    safeNotify();
  }

  /// Folds pushes received while the app was backgrounded or terminated into the
  /// list. Called on every resume — the background isolate can only write to its
  /// own queue, never to the canonical list.
  Future<void> drainBackgroundQueue({bool persist = true}) async {
    final pending = await _store.drainPending();
    if (pending.isEmpty) return;

    var added = false;
    for (final json in pending) {
      final payload = PushPayload.fromJson(json);
      if (_insert(payload)) added = true;
    }
    if (!added) return;

    _sortAndCap();
    if (persist) {
      await _persist();
      safeNotify();
    }
  }

  /// Records a push received while the app was in the foreground.
  Future<void> ingest(PushPayload payload) async {
    if (!_insert(payload)) return;
    _sortAndCap();
    await _persist();
    safeNotify();
  }

  /// Returns false when the id is already present (FCM can redeliver, and a tap
  /// re-surfaces a message the foreground handler may already have stored).
  bool _insert(PushPayload payload) {
    if (_items.any((n) => n.id == payload.id)) return false;
    _items.insert(
      0,
      NotifItem.fromPush(payload, route: resolvePushRouteForCurrentRole(payload)),
    );
    return true;
  }

  void _sortAndCap() {
    _items.sort((a, b) => b.at.compareTo(a.at));
    if (_items.length > NotificationInboxStore.maxItems) {
      _items.removeRange(NotificationInboxStore.maxItems, _items.length);
    }
  }

  Future<void> _persist() =>
      _store.writeInbox(_items.map((n) => n.toJson()).toList());

  /// Wipes the inbox on sign-out. Notifications are per-user; a second account
  /// on the same device must not inherit the first's.
  Future<void> clearForSignOut() async {
    _items.clear();
    _tab = 0;
    await _store.clear();
    safeNotify();
  }

  // ── mutations (signatures unchanged — widgets pass these as tear-offs) ────

  void markAllRead() {
    for (final n in _items) {
      n.isRead = true;
    }
    unawaited(_persist());
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    unawaited(_persist());
    notifyListeners();
  }

  void dismiss(String id) {
    _items.removeWhere((n) => n.id == id);
    unawaited(_persist());
    notifyListeners();
  }

  void toggleRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i != -1) {
      _items[i].isRead = !_items[i].isRead;
      unawaited(_persist());
      notifyListeners();
    }
  }

  /// Marks an item read on open and hands back its route, if any.
  String? openAndMarkRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1) return null;
    if (!_items[i].isRead) {
      _items[i].isRead = true;
      unawaited(_persist());
      notifyListeners();
    }
    return _items[i].route;
  }
}
