import 'package:rm_app_flutter_core/core/event_bus/events/domain_event.dart';

abstract class LangEvents extends DomainEvent {}

class ChangeLanguage extends LangEvents {
  ChangeLanguage();
}
