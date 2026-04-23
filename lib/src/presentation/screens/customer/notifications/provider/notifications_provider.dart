import 'package:flutter/material.dart';

import '../data/notifications_mock_data.dart';
import '../models/notif_item.dart';

class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider() {
    _items = seedNotifs();
  }

  late List<NotifItem> _items;
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

  int countForTab(int i) {
    if (i == 0) return _items.length;
    return _items.where((n) => n.category == categoryMap[i]).length;
  }

  void setTab(int i) {
    if (_tab == i) return;
    _tab = i;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _items) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }

  void dismiss(String id) {
    _items.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void toggleRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i != -1) {
      _items[i].isRead = !_items[i].isRead;
      notifyListeners();
    }
  }
}
