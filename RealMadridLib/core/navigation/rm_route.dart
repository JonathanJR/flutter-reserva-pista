import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_core/state_management.dart';

abstract class RMRoute extends GoRoute {
  final Ref ref;

  RMRoute({
    required this.ref,
    required super.path,
    required super.name,
    super.builder,
    super.pageBuilder,
    super.routes,
  });
}
