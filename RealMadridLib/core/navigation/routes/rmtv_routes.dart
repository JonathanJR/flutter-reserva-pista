import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/rmtv/views/rmtv_view.dart';

final List<GoRoute> rmtvRoutes = [
  GoRoute(
    path: RMFanRoutes.rmtv.path,
    name: RMFanRoutes.rmtv.name,
    pageBuilder: (context, state) => MaterialPage(
      name: RMFanRoutes.rmtv.name,
      child: const RmtvPage(),
    ),
  ),
];
