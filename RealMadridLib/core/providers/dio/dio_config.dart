import 'package:rm_app_flutter_core/data/data.dart';

class DioConfig extends RMDioConfig {
  final String microServiceName;

  DioConfig({
    required this.microServiceName,
    super.cacheOptions,
  });
}

class AemDioConfig extends RMDioConfig {
  final String keyByPath;

  AemDioConfig({
    required this.keyByPath,
    super.cacheOptions,
  });
}
