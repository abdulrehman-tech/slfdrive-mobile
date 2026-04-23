import 'dart:async';

import 'package:flutter/material.dart';

class OtpProvider extends ChangeNotifier {
  OtpProvider({required this.phoneNumber, required this.isDriver, required this.deliveryMethod}) {
    for (int i = 0; i < _length; i++) {
      _controllers[i].addListener(_validate);
    }
    _startResendTimer();
  }

  static const int _length = 6;

  final String phoneNumber;
  final bool isDriver;
  final String deliveryMethod;

  final List<TextEditingController> _controllers = List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_length, (_) => FocusNode());

  List<TextEditingController> get controllers => _controllers;
  List<FocusNode> get focusNodes => _focusNodes;
  int get length => _length;

  bool _isButtonEnabled = false;
  bool get isButtonEnabled => _isButtonEnabled;

  int _resendTimer = 60;
  int get resendTimer => _resendTimer;
  bool get canResend => _resendTimer == 0;

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
    _resendTimer = 60;
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
    if (enabled != _isButtonEnabled) {
      _isButtonEnabled = enabled;
      notifyListeners();
    }
  }

  void handleInput(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < digits.length && (index + i) < _length; i++) {
        _controllers[index + i].text = digits[i];
        _controllers[index + i].selection = const TextSelection.collapsed(offset: 1);
      }
      final nextFocus = (index + digits.length).clamp(0, _length - 1);
      _focusNodes[nextFocus].requestFocus();
      _validate();
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
    // TODO: Resend OTP
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
