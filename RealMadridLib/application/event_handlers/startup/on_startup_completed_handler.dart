import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/domain/events/startup/startup_events.dart';

class OnStartupCompletedHandler
    extends DomainEventHandler<AppStartupCompleted> {
  final ProviderContainer container;

  OnStartupCompletedHandler(this.container);

  @override
  Future<void> handle(AppStartupCompleted event) async {
    logDebug('App startup completed');
  }
}
