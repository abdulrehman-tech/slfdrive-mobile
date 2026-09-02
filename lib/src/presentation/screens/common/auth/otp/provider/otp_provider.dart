import 'dart:async';

import 'package:flutter/material.dart';

class OtpProvider extends ChangeNotifier {
  OtpProvider({required this.phoneNumber, required this.isDriver, required this.deliveryMethod, required this.userId}) {
    for (int i = 0; i < _length; i++) {
      _controllers[i].addListener(_validate);
    }
    _startResendTimer();
  }

  static const int _length = 6;

  final String phoneNumber;
  final bool isDriver;
  final String deliveryMethod;
  final int userId;

  /// Set by the screen to re-request an OTP via the auth API on resend.
  Future<void> Function()? onResend;

  /// Fired once the sixth digit lands — however it arrived: typed, pasted, or
  /// filled by the OS from the SMS. The screen wires this to the same verify
  /// path as the button, so the button becomes a fallback rather than a step.
  void Function()? onCompleted;

  final List<TextEditingController> _controllers = List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_length, (_) => FocusNode());

  List<TextEditingController> get controllers => _controllers;
  List<FocusNode> get focusNodes => _focusNodes;
  int get length => _length;

  bool _isButtonEnabled = false;
  bool get isButtonEnabled => _isButtonEnabled;

  // Seconds the user must wait before requesting a new OTP (2 minutes).
  static const int _resendCooldown = 120;

  int _resendTimer = _resendCooldown;
  int get resendTimer => _resendTimer;
  bool get canResend => _resendTimer == 0;

  /// Remaining cooldown as `m:ss` (e.g. `2:00`, `0:45`).
  String get resendTimerLabel {
    final m = _resendTimer ~/ 60;
    final s = (_resendTimer % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Timer? _timer;

  String get otpCode => _controllers.map((c) => c.text).join();

  void requestFirstFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startResendTimer() {
    _resendTimer = _resendCooldown;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        _resendTimer--;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _validate() {
    final enabled = _controllers.every((controller) => controller.text.isNotEmpty);
    if (enabled == _isButtonEnabled) return;
    _isButtonEnabled = enabled;
    notifyListeners();
    if (enabled) {
      // Deferred: this runs inside a TextEditingController listener, and the
      // callback navigates and shows snackbars.
      scheduleMicrotask(() => onCompleted?.call());
    }
  }

  void _setCell(int index, String char) {
    _controllers[index].text = char;
    _controllers[index].selection = TextSelection.collapsed(offset: char.length);
  }

  /// Lays the whole code out from the first cell and drops the keyboard.
  void _fillAll(String digits) {
    for (int i = 0; i < _length; i++) {
      _setCell(i, digits[i]);
    }
    unfocusAll();
    _validate();
  }

  void unfocusAll() {
    for (final node in _focusNodes) {
      node.unfocus();
    }
  }

  /// Clears every cell and returns focus to the first — used after a rejected
  /// code so the next attempt can auto-submit again instead of sitting in a
  /// full-but-wrong state.
  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _validate();
    _focusNodes[0].requestFocus();
  }

  void handleInput(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // The whole code arriving at once: SMS autofill or a paste. Lay it out from
    // cell 0 regardless of which cell happened to be focused.
    if (digits.length >= _length) {
      _fillAll(digits.substring(0, _length));
      return;
    }

    // Two characters means the user typed over an already-filled cell. Keep what
    // they just typed, not the stale digit.
    if (digits.length == 2) {
      _setCell(index, digits[1]);
      if (index < _length - 1) _focusNodes[index + 1].requestFocus();
      return;
    }

    // A partial paste (3-5 digits): spread it from the current cell.
    if (digits.length > 2) {
      for (int i = 0; i < digits.length && (index + i) < _length; i++) {
        _setCell(index + i, digits[i]);
      }
      _focusNodes[(index + digits.length).clamp(0, _length - 1)].requestFocus();
      return;
    }

    // A single non-digit slipped past the formatter — drop it.
    if (digits.isEmpty && value.isNotEmpty) {
      _setCell(index, '');
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  bool resend() {
    if (!canResend) return false;
    onResend?.call();
    _startResendTimer();
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }
}
