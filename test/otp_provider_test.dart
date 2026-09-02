import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/presentation/screens/common/auth/otp/provider/otp_provider.dart';

OtpProvider build() => OtpProvider(
      phoneNumber: '+96890000000',
      isDriver: false,
      deliveryMethod: 'sms',
      userId: 1,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OtpProvider p;
  setUp(() => p = build());
  tearDown(() => p.dispose());

  /// Mirrors what a TextField does before calling onChanged: the controller
  /// already holds the new value.
  void type(int index, String value) {
    p.controllers[index].text = value;
    p.handleInput(index, value);
  }

  test('a full code autofills across every cell from the first', () async {
    // iOS hands the whole SMS code to whichever cell is focused — here cell 3.
    type(3, '123456');

    expect(p.otpCode, '123456');
    expect(p.controllers.map((c) => c.text).toList(),
        ['1', '2', '3', '4', '5', '6']);
    expect(p.isButtonEnabled, isTrue);
  });

  test('a longer autofill string is truncated to the code length', () {
    type(0, '1234567890');
    expect(p.otpCode, '123456');
  });

  test('typing over a filled cell keeps the new digit, not the stale one', () {
    type(0, '1');
    expect(p.controllers[0].text, '1');

    // Cursor sits after the existing digit, so the field reports "19".
    type(0, '19');
    expect(p.controllers[0].text, '9');
  });

  test('a partial paste spreads from the focused cell', () {
    type(2, '456');
    expect(p.controllers.map((c) => c.text).toList(),
        ['', '', '4', '5', '6', '']);
    expect(p.isButtonEnabled, isFalse);
  });

  test('onCompleted fires once when the last digit lands', () async {
    var calls = 0;
    p.onCompleted = () => calls++;

    for (var i = 0; i < 5; i++) {
      type(i, '${i + 1}');
    }
    await Future<void>.delayed(Duration.zero);
    expect(calls, 0, reason: 'still incomplete');

    type(5, '6');
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
  });

  test('onCompleted fires once for an autofill, not once per cell', () async {
    var calls = 0;
    p.onCompleted = () => calls++;

    type(0, '123456');
    await Future<void>.delayed(Duration.zero);

    expect(calls, 1);
  });

  test('clear() resets the code so the next attempt can auto-submit again',
      () async {
    var calls = 0;
    p.onCompleted = () => calls++;

    type(0, '123456');
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);

    p.clear();
    expect(p.otpCode, isEmpty);
    expect(p.isButtonEnabled, isFalse);

    type(0, '654321');
    await Future<void>.delayed(Duration.zero);
    expect(calls, 2, reason: 'a retry must re-trigger auto-verify');
  });

  test('non-digit input is rejected', () {
    type(0, 'a');
    expect(p.controllers[0].text, isEmpty);
  });
}
