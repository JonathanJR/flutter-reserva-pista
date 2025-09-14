import '../../domain/repositories/remote_config_repository.dart';
import '../datasources/remote_config_datasource.dart';

/// Implementación del repository de Remote Config
class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  final RemoteConfigDataSource _dataSource;

  const RemoteConfigRepositoryImpl(this._dataSource);

  @override
  Future<void> initialize() {
    return _dataSource.initialize();
  }

  @override
  int getMaxDaysAdvance() {
    return _dataSource.getMaxDaysAdvance();
  }

  @override
  bool getBool(String key) {
    return _dataSource.getBool(key);
  }

  @override
  int getInt(String key) {
    return _dataSource.getInt(key);
  }

  @override
  double getDouble(String key) {
    return _dataSource.getDouble(key);
  }

  @override
  String getString(String key) {
    return _dataSource.getString(key);
  }

  @override
  Future<bool> forceRefresh() {
    return _dataSource.forceRefresh();
  }
  
  @override
  Map<String, dynamic> getDebugInfo() {
    return _dataSource.getDebugInfo();
  }
}
