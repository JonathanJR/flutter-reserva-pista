

import 'package:rm_app_flutter_core/code.dart';

enum RMFanRoutes {

  // Home
  home,

  // news
  news,

  // Calendar
  calendar,

  // RMTV
  rmtv,

  // Shop
  shop,

  assistant,

  // Profile
  profile,
 

  // Maintenance Mode
  maintenance,
  updateRequired;

  String get path => '/$name';
  String get subPath => name;

  bool isPrimary() {
    return this == home || this == news || this == rmtv || this == calendar || this == shop;
  }

  static RMFanRoutes? routeNameToRoutes(String currentRouteName) {
    return RMFanRoutes.values.firstWhereOrNull(
      (element) => element.name == currentRouteName,
    );
  }
}
