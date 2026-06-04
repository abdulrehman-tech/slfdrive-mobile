import '../../models/lookup/location_option.dart';
import '../datasources/lookup_remote_data_source.dart';

/// Exposes shared lookup lists to the presentation layer.
abstract class LookupRepository {
  Future<List<LocationOption>> getActiveLocations();
}

class LookupRepositoryImpl implements LookupRepository {
  final LookupRemoteDataSource remote;

  LookupRepositoryImpl(this.remote);

  @override
  Future<List<LocationOption>> getActiveLocations() => remote.getActiveLocations();
}
