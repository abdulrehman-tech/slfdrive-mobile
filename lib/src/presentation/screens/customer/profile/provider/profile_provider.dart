import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider() {
    scroll.addListener(_onScroll);
  }

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  final ScrollController scroll = ScrollController();
  double _scrollOffset = 0;
  double get scrollOffset => _scrollOffset;

  void _onScroll() {
    final next = scroll.offset.clamp(0, 200).toDouble();
    if ((next - _scrollOffset).abs() > 0.5) {
      _scrollOffset = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
