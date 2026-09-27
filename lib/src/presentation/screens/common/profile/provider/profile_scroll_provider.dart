import 'package:flutter/material.dart';

/// Scroll position of a profile page, driving the glass header's fade-in.
/// Shared by the customer and driver profile screens.
class ProfileScrollProvider extends ChangeNotifier {
  ProfileScrollProvider() {
    scroll.addListener(_onScroll);
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
