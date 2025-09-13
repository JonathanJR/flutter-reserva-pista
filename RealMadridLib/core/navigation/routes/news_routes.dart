import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/news/views/news_view.dart';

final List<GoRoute> newsRoutes = [
  GoRoute(
    path: RMFanRoutes.news.path,
    name: RMFanRoutes.news.name,
    pageBuilder: (context, state) => MaterialPage(
      name: RMFanRoutes.news.name,
      child: const NewsPage(),
    ),
  ),
];
