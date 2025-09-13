import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/auth/auth_handler.dart';
import 'package:rm_app_flutter_fan/application/providers/domain_events_provider.dart';
import 'package:rm_app_flutter_fan/domain/enums/logout_reason.dart';
import 'package:rm_app_flutter_fan/domain/events/auth/auth_events.dart';


class OnUserLoggedInHandler extends DomainEventHandler<UserLoggedIn>
    with AuthHandler {
  @override
  final ProviderContainer container;

  OnUserLoggedInHandler(this.container);

  @override
  Future<void> handle(UserLoggedIn event) async {
    logDebug(
      'User log in, fetching user...',
    );

    try {
      // await container.read(authStorageProvider).storeCredentials(
      //       accountId: event.accountId,
      //       password: event.password,
      //     );

      await handleLogin();
    } catch (e) {
      container.read(eventBusProvider).publish(
            UserLoggedOut(
              reason: LogoutReason.invalidInitialization,
            ),
          );
    }
  }
}
