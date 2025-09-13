import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/presentation/rmtv/state/rmtv_state.dart';

part 'rmtv_notifier.g.dart';

@riverpod
class RmtvNotifier extends _$RmtvNotifier {
  @override
  RmtvState build() => RmtvState.initial();
}
