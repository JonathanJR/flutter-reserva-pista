import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/auth/auth_handler.dart';
import 'package:rm_app_flutter_fan/application/providers/domain_events_provider.dart';
import 'package:rm_app_flutter_fan/domain/enums/logout_reason.dart';
import 'package:rm_app_flutter_fan/domain/events/auth/auth_events.dart';


class OnAuthCheckHandler extends DomainEventHandler<AuthChecked> with AuthHandler {
  @override
  final ProviderContainer container;
  final IEventBus eventBus;

  OnAuthCheckHandler(
    this.container, {
    required this.eventBus,
  });

  @override
  Future<void> handle(AuthChecked event) async {
    switch (event) {
      case AuthCheckFailed():
        logDebug('AuthCheckFailed');

      case AuthCheckSuccessful():
        try {
          await handleLogin();
        } catch (e) {
          logError(e.toString());
          container.read(eventBusProvider).publish(
                UserLoggedOut(
                  reason: LogoutReason.invalidInitialization,
                ),
              );
        }
    }
  }
}
