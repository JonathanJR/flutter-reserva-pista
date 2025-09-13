import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/auth/on_auth_check_handler.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/auth/on_user_logged_in_handler.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/auth/on_user_logged_out_handler.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/lang/on_change_lang_handler.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/startup/on_startup_completed_handler.dart';
import 'package:rm_app_flutter_fan/application/event_handlers/startup/on_startup_failed_handler.dart';
import 'package:rm_app_flutter_fan/domain/events/auth/auth_events.dart';
import 'package:rm_app_flutter_fan/domain/events/lang/lang_events.dart';
import 'package:rm_app_flutter_fan/domain/events/startup/startup_events.dart';

class RMFanEventBusObserver extends RMEventBusObserver {
  RMFanEventBusObserver(super.eventBus);

  @override
  void initializeEventSubscribers(ProviderContainer container) {
    _addAppSubscribers(container);
    _addAuthSubscribers(container);
   // _addDeepLinkSubscribers(container);
    _addLangSubscribers(container);
  }

  void _addAppSubscribers(ProviderContainer container) {
    subscribeTo<AppStartupCompleted>(
      OnStartupCompletedHandler(container),
    );
    subscribeTo<AppStartupFailed>(
      OnStartupFailedHandler(container),
    );
  }

  void _addAuthSubscribers(ProviderContainer container) {
    subscribeTo<UserLoggedIn>(
      OnUserLoggedInHandler(container),
    );

    subscribeTo<UserLoggedOut>(
      OnUserLoggedOutHandler(container),
    );

    subscribeTo<AuthChecked>(
      OnAuthCheckHandler(
        container,
        eventBus: eventBus,
      ),
    );
  }

  // void _addDeepLinkSubscribers(ProviderContainer container) {
  //   subscribeTo<MyOrder>(
  //     OnMyOrderHandler(container),
  //   );
  // }

  void _addLangSubscribers(ProviderContainer container) {
    subscribeTo<ChangeLanguage>(
      OnChangeLangHandler(container),
    );
  }
}
