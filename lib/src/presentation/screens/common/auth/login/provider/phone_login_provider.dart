import 'package:flutter/foundation.dart';

class PhoneLoginProvider extends ChangeNotifier {
  PhoneLoginProvider({required this.isDriver});

  final bool isDriver;

  String _completePhoneNumber = '';
  String _dialCode = '';
  String _selectedDeliveryMethod = 'sms';
  bool _isButtonEnabled = false;

  String get completePhoneNumber => _completePhoneNumber;
  String get dialCode => _dialCode;
  String get selectedDeliveryMethod => _selectedDeliveryMethod;
  bool get isButtonEnabled => _isButtonEnabled;

  void onPhoneChanged(String completeNumber, String dialCode) {
    _completePhoneNumber = completeNumber;
    _dialCode = dialCode;
    final enabled = completeNumber.isNotEmpty && completeNumber.length >= (dialCode.length + 8);
    if (enabled != _isButtonEnabled) {
      _isButtonEnabled = enabled;
    }
    notifyListeners();
  }

  void selectDeliveryMethod(String method) {
    if (_selectedDeliveryMethod == method) return;
    _selectedDeliveryMethod = method;
    notifyListeners();
  }
}
