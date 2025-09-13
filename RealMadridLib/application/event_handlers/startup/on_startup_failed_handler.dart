import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/domain/events/startup/startup_events.dart';


class OnStartupFailedHandler extends DomainEventHandler<AppStartupFailed> {
  final ProviderContainer container;

  OnStartupFailedHandler(this.container);

  @override
  Future<void> handle(AppStartupFailed event) async {
    logDebug('App startup failed: ${event.reason}');
  }
}
