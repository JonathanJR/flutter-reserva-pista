import 'package:rm_app_flutter_core/core/core.dart';

abstract class StartupEvents extends DomainEvent {}

class AppStartupCompleted extends StartupEvents {
  AppStartupCompleted();
}

class AppStartupFailed extends StartupEvents {
  final String reason;

  AppStartupFailed(this.reason);
}
