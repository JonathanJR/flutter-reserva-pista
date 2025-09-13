import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/shop/views/shop_view.dart';

final List<GoRoute> shopRoutes = [
  GoRoute(
    path: RMFanRoutes.shop.path,
    name: RMFanRoutes.shop.name,
    pageBuilder: (context, state) => MaterialPage(
      name: RMFanRoutes.shop.name,
      child: const ShopPage(),
    ),
  ),
];
