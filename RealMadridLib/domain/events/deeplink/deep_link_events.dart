import 'package:rm_app_flutter_core/core/core.dart';

abstract class DeepLinkEvents extends DomainEvent {}

class RedirectingDeepLink extends DeepLinkEvents {
  RedirectingDeepLink();
}

class MyOrder extends DeepLinkEvents {
  final String id;
  MyOrder(this.id);
}
