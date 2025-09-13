import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/calendar/views/calendar_view.dart';

final List<GoRoute> calendarRoutes = [
  GoRoute(
    path: RMFanRoutes.calendar.path,
    name: RMFanRoutes.calendar.name,
    pageBuilder: (context, state) => MaterialPage(
      name: RMFanRoutes.calendar.name,
      child: const CalendarPage(),
    ),
  ),
];
