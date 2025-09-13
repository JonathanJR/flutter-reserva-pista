import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/application/observers/rm_fan_event_bus_observer.dart';

final eventBusProvider = Provider<IEventBus>(
  (ref) => EventBusImpl(),
  name: 'eventBus',
);

final domainEventObserverProvider = Provider<RMFanEventBusObserver>(
  (ref) {
    final domainEventsObserver =
        RMFanEventBusObserver(ref.watch(eventBusProvider));

    ref.onDispose(domainEventsObserver.dispose);

    return domainEventsObserver;
  },
  name: 'domainEventObserver',
);
