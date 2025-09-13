import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/data/models/toast_config.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_router.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/domain/events/auth/auth_events.dart';
import 'package:toastification/toastification.dart';



class OnUserLoggedOutHandler extends DomainEventHandler<UserLoggedOut> {
  final ProviderContainer container;

  OnUserLoggedOutHandler(this.container);

  bool _isHandling = false;

  @override
  Future<void> handle(UserLoggedOut event) async {
    if (_isHandling) return;
    _isHandling = true;

    logDebug('Handling UserLoggedOut event...');

    if (event.reason.label.isNotEmpty) {
      container.read(toastNotifierProvider.notifier).showToast(
            ToastConfig(
              message: event.reason.label,
              type: ToastificationType.error,
            ),
          );
    }

    try {
      // await container.read(loginNotifierProvider.notifier).resetStatus();
      // container
      //     .read(authNotifierProvider.notifier)
      //     .updateStatus(status: AuthStatus.unauthenticated);

      // await container.read(indigitallProvider).logout();
      container.read(routerProvider).goNamed(RMFanRoutes.home.name);
    } catch (e) {
      logDebug(e);
    }
    _isHandling = false;
  }
}
