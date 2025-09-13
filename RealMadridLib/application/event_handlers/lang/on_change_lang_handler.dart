import 'dart:async';

import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_router.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/domain/events/lang/lang_events.dart';

class OnChangeLangHandler extends DomainEventHandler<ChangeLanguage> {
  final ProviderContainer container;

  OnChangeLangHandler(this.container);

  @override
  Future<void> handle(ChangeLanguage event) async {
    logDebug('Deactivating lang notifiers...');
    // final localizationCode =
    //     container.read(languageNotifierProvider.notifier).localizationCode;
    // await container
    //     .read(userNotifierProvider.notifier)
    //     .fetchUser(localizationCode);
    container.invalidate(routerProvider);
    container.read(routerProvider).goNamed(RMFanRoutes.home.name);
  }
}
