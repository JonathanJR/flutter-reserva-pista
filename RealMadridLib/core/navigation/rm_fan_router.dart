import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/code.dart';
import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/core/navigation/routes/home_routes.dart';
import 'package:rm_app_flutter_fan/core/navigation/routes/news_routes.dart';
import 'package:rm_app_flutter_fan/core/navigation/routes/calendar_routes.dart';
import 'package:rm_app_flutter_fan/core/navigation/routes/rmtv_routes.dart';
import 'package:rm_app_flutter_fan/core/navigation/routes/shop_routes.dart';
import 'package:rm_app_flutter_fan/presentation/main_navigation/views/main_navigation_scaffold.dart';
import 'package:rm_app_flutter_fan/presentation/common/maintenance_mode/maintenance_mode.dart';
import 'package:rm_app_flutter_fan/data/router_guard/rm_fan_router_guard.dart';

class VipRouter extends RmRouter {
  static final homeNavigationState = GlobalKey<NavigatorState>(
    debugLabel: 'homeNavigationState',
  );

  VipRouter(Ref ref)
    : super(
        routingConfig: RMRoutingConfig(
          RoutingConfig(
            routes: [
              GoRoute(
                path: RMFanRoutes.maintenance.path,
                name: RMFanRoutes.maintenance.name,
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  name: RMFanRoutes.maintenance.name,
                  child: const RMFanMaintenanceMode.general(),
                ),
              ),
              GoRoute(
                path: RMFanRoutes.updateRequired.path,
                name: RMFanRoutes.updateRequired.name,
                pageBuilder: (context, state) => MaterialPage(
                  key: state.pageKey,
                  name: RMFanRoutes.updateRequired.name,
                  child: const RMFanMaintenanceMode.requireUpdate(),
                ),
              ),
              StatefulShellRoute.indexedStack(
                builder:
                    (
                      BuildContext context,
                      GoRouterState state,
                      StatefulNavigationShell navigationShell,
                    ) {
                      // This route is for get the main route of stack,
                      // not the target, for that reason use state.topRoute
                      final mainRoute = RMFanRoutes.values.firstWhereOrNull(
                        (element) =>
                            element.name ==
                            state.matchedLocation.replaceFirst('/', ''),
                      );

                      return MainNavigationScaffold(
                        navigationShell: navigationShell,
                        route: mainRoute,
                      );
                    },
                branches: [
                  StatefulShellBranch(
                    initialLocation: RMFanRoutes.home.path,
                    routes: homeRoutes,
                  ),
                  StatefulShellBranch(
                    initialLocation: RMFanRoutes.news.path,
                    routes: newsRoutes,
                  ),
                  StatefulShellBranch(
                    initialLocation: RMFanRoutes.calendar.path,
                    routes: calendarRoutes,
                  ),
                  StatefulShellBranch(
                    initialLocation: RMFanRoutes.rmtv.path,
                    routes: rmtvRoutes,
                  ),
                  StatefulShellBranch(
                    initialLocation: RMFanRoutes.shop.path,
                    routes: shopRoutes,
                  ),
                ],
              ),
              // ...profileRoutes,
              // ...loginRoutes,
              // ...calendarRoutes,
              // ...walletRoutes,
            ],
            redirect: [
              RMFanRouterGuard(
                // deepLinkHandlerNotifier:
                //     ref.read(deepLinkHandlerNotifierProvider.notifier),
                // allowedWithoutCredentials: [
                //   _loginPath(RMFanRoutes.loginHelpAccess.path),
                //   _loginPath(RMFanRoutes.loginEmailSent.path),
                //   _loginPath(RMFanRoutes.loginCreateNewPassword.path),
                //   _loginPath(RMFanRoutes.loginPassword.path),
                // ],
                // isAuthenticated: (context, state) {
                //   final status = ref.read(
                //     authNotifierProvider.select((value) => value),
                //   );
                //   return status == AuthStatus.authenticated;
                // },
                allowedWithoutChecks: [
                  RMFanRoutes.maintenance.path,
                  RMFanRoutes.updateRequired.path,
                ],
                // generalRedirect: (context, state) => RMFanRoutes.login.path,
                maintenanceRedirect: (context, state) =>
                    RMFanRoutes.maintenance.path,
                updateRequiredRedirect: (context, state) =>
                    RMFanRoutes.updateRequired.path,
                // hasCredentialsChecker: () =>
                //     ref.read(authStorageProvider).hasCredentials(ref),
                // credentialsRedirect: (context, state) =>
                //     '${RMFanRoutes.login.path}${RMFanRoutes.loginPassword.path}',
              ),
            ].guard,
          ),
        ),
        initialLocation: RMFanRoutes.home.path,
        // observers: [FirebaseScreenObserver(), AdobeScreenObserver()],
        ref: ref,
      );
}

final routerProvider = Provider(VipRouter.new, name: 'router');
