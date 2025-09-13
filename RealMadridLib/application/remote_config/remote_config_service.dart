import 'package:rm_app_flutter_fan/application/remote_config/fan_remote_config.dart';

class RemoteConfigService {
  static FanRemoteConfig? _config;

  static void setConfig(FanRemoteConfig config) {
    _config = config;
  }

  static FanRemoteConfig? get config => _config;

  static String get minimumAppVersion => _config?.getMinimumAppVersion ?? '1.0.0';

  static bool get isMaintenanceMode => _config?.isMaintenanceMode ?? false;

  static String? get maintenanceReason => _config?.maintenance.reason;

  static void clearConfig() {
    _config = null;
  }
}
