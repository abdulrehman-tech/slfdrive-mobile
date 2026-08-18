import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/data/repositories/driver_repository.dart';
import 'package:slfdrive/src/core/models/driver/driver_details.dart';
import 'package:slfdrive/src/core/models/driver/driver_stats.dart';
import 'package:slfdrive/src/core/services/driver_session.dart';

class GatedDriverRepository implements DriverRepository {
  DriverDetails? details;
  Completer<void>? gate;
  int getByIdCalls = 0;

  @override
  Future<DriverDetails?> getById(int id) async {
    getByIdCalls++;
    if (gate != null) await gate!.future;
    return details;
  }

  @override
  Future<DriverStats?> getStats(int id) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class MapStorage implements FlutterSecureStorage {
  final Map<String, String> data;
  final List<String> writtenKeys = [];

  MapStorage(this.data);

  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async =>
      data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    writtenKeys.add(key);
    if (value != null) data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('concurrent driverId lookups share one GET', () async {
    final repo = GatedDriverRepository()..details = const DriverDetails(id: 42, driverId: 7);
    final storage = MapStorage({'user_id': '42'});
    final session = DriverSession(repo, storage);
    final results = await Future.wait([session.driverId(), session.driverId(), session.driverId()]);
    expect(repo.getByIdCalls, 1);
    expect(results, [7, 7, 7]);
  });

  test('clear() mid-lookup discards the previous account\'s id (no cache, no persist)', () async {
    final repo = GatedDriverRepository()
      ..details = const DriverDetails(id: 42, driverId: 7)
      ..gate = Completer<void>();
    final storage = MapStorage({'user_id': '42'});
    final session = DriverSession(repo, storage);

    final stale = session.driverId();
    // Logout while the lookup is in flight: auth layer clears storage + session.
    storage.data.remove('user_id');
    storage.data.remove('driver_id');
    session.clear();
    repo.gate!.complete();
    repo.gate = null;
    expect(await stale, isNull);
    // Nothing from the old account may be cached or re-persisted.
    expect(storage.writtenKeys, isEmpty);
    expect(storage.data.containsKey('driver_id'), isFalse);

    // Next account resolves fresh.
    storage.data['user_id'] = '99';
    repo.details = const DriverDetails(id: 99, driverId: 21);
    expect(await session.driverId(), 21);
  });
}
