import 'package:flutter/foundation.dart';

/// Guards [ChangeNotifier]s whose async work can outlive the widget tree
/// (long await chains — network fan-outs, geocoding loops). Call [safeNotify]
/// instead of [notifyListeners] anywhere an `await` may have preceded it:
/// after dispose it becomes a no-op instead of throwing.
mixin SafeNotifier on ChangeNotifier {
  bool _disposed = false;

  bool get isDisposed => _disposed;

  void safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
