import 'package:rm_app_flutter_core/data/models/remote_config_model.dart';

class FanRemoteConfig extends RemoteConfigModel {
  const FanRemoteConfig({
    required super.maintenance,
    super.cache,
  });

  factory FanRemoteConfig.fromJson(Map<String, dynamic> json) {
    final configuration = json['configuration'] as Map<String, dynamic>? ?? {};
    final maintenanceConfig = configuration['maintenance'] as Map<String, dynamic>? ?? {};
    
    return FanRemoteConfig(
      maintenance: MaintenanceRemoteConfigModel(
        maintenanceMode: maintenanceConfig['enabled'] as bool? ?? false,
        minimumAppVersion: configuration['minVersion'] as String? ?? '0.0.0',
        reason: maintenanceConfig['reason'] as String?,
      ),
      cache: null, // No cache information in remote features-configuration JSON
    );
  }
}
