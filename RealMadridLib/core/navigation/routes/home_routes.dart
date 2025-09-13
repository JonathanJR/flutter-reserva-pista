import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/navigation.dart';

import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/home/views/home_view.dart';

final List<GoRoute> homeRoutes = [
  GoRoute(
    path: RMFanRoutes.home.path,
    name: RMFanRoutes.home.name,
    pageBuilder: (context, state) => MaterialPage(
      name: RMFanRoutes.home.name,
      child: const HomePage(),
    ),
  ),
];
