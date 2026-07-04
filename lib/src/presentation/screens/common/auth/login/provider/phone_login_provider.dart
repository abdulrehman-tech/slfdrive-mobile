import 'package:flutter/foundation.dart';

class PhoneLoginProvider extends ChangeNotifier {
  PhoneLoginProvider({required this.isDriver});

  final bool isDriver;

  String _completePhoneNumber = '';
  String _dialCode = '';
  // OTP delivery channel. The in-app selector was removed; SMS is the default
  // channel sent to the backend behind the scenes.
  String _selectedDeliveryMethod = 'sms';
  bool _phoneValid = false;
  bool _acceptedTerms = false;

  String get completePhoneNumber => _completePhoneNumber;
  String get dialCode => _dialCode;
  String get selectedDeliveryMethod => _selectedDeliveryMethod;
  bool get acceptedTerms => _acceptedTerms;

  /// Continue is allowed only once the phone number is valid AND the user has
  /// accepted the Terms & Privacy checkbox.
  bool get isButtonEnabled => _phoneValid && _acceptedTerms;

  void onPhoneChanged(String completeNumber, String dialCode) {
    _completePhoneNumber = completeNumber;
    _dialCode = dialCode;
    _phoneValid = completeNumber.isNotEmpty && completeNumber.length >= (dialCode.length + 8);
    notifyListeners();
  }

  void setAcceptedTerms(bool value) {
    if (_acceptedTerms == value) return;
    _acceptedTerms = value;
    notifyListeners();
  }

  void selectDeliveryMethod(String method) {
    if (_selectedDeliveryMethod == method) return;
    _selectedDeliveryMethod = method;
    notifyListeners();
  }
}
