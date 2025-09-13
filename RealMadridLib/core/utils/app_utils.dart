import 'package:rm_app_flutter_core/rm_core_initialization.dart';

class RMFanAppUtils {
  static bool isUpdateRequired(String minimumAppVersion) {
    final actualMinVersion = int.parse(
      RMCoreInitialization.packageInfo!.version.replaceAll('.', ''),
    );

    final requiredMinVersion = int.parse(minimumAppVersion.replaceAll('.', ''));

    return actualMinVersion < requiredMinVersion;
  }
}
