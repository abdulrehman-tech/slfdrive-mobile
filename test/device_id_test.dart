import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/constants/storage_keys.dart';
import 'package:slfdrive/src/core/utils/device_id.dart';

const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> keychain;
  late int writeCount;
  late bool failFirstWrite;
  // Value a concurrent writer lands between our read and our write.
  String? raceWinner;

  setUp(() {
    resetDeviceIdCache();
    keychain = {};
    writeCount = 0;
    failFirstWrite = false;
    raceWinner = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      final args = Map<String, dynamic>.from(call.arguments as Map);
      final key = args['key'] as String?;
      switch (call.method) {
        case 'read':
          return keychain[key];
        case 'write':
          writeCount++;
          if (failFirstWrite && writeCount == 1) {
            // Exactly what iOS raised in the field: a concurrent writer already
            // inserted the item, so it is now visible to a re-read.
            if (raceWinner != null) keychain[key!] = raceWinner!;
            throw PlatformException(
              code: '-25299',
              message: 'The specified item already exists in the keychain.',
            );
          }
          keychain[key!] = args['value'] as String;
          return null;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  const storage = FlutterSecureStorage();

  test('an existing id is reused, never rewritten', () async {
    keychain[StorageKeys.deviceId] = 'existing-id';
    expect(await ensureDeviceId(storage), 'existing-id');
    expect(writeCount, 0);
  });

  test('concurrent callers resolve one id with a single write', () async {
    // The real trigger: syncToken() fires from session hydration, _applyUser and
    // the permission grant at nearly the same moment.
    final results = await Future.wait([
      ensureDeviceId(storage),
      ensureDeviceId(storage),
      ensureDeviceId(storage),
    ]);

    expect(results.toSet(), hasLength(1), reason: 'all callers must agree');
    expect(writeCount, 1, reason: 'the write must not be raced');
    expect(keychain[StorageKeys.deviceId], results.first);
  });

  test('a duplicate-item write failure yields to the value that landed', () async {
    // The keychain starts empty, so we get past the early read and actually
    // attempt a write — which then fails with -25299 because another writer won
    // in between. The re-read must win, so both callers agree on one id.
    failFirstWrite = true;
    raceWinner = 'winner-id';

    expect(await ensureDeviceId(storage), 'winner-id');
    expect(writeCount, 1);
  });

  test('a write failure with nothing persisted still returns a usable id', () async {
    failFirstWrite = true; // and raceWinner stays null: nothing landed

    final id = await ensureDeviceId(storage);
    expect(id, isNotEmpty);
  });

  test('the resolved id is cached in memory across calls', () async {
    final first = await ensureDeviceId(storage);
    keychain.clear(); // a later read would return null if it hit the keychain
    expect(await ensureDeviceId(storage), first);
    expect(writeCount, 1);
  });
}
