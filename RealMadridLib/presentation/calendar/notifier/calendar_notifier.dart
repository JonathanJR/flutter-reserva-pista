import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/presentation/calendar/state/calendar_state.dart';

part 'calendar_notifier.g.dart';

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  @override
  CalendarState build() => CalendarState.initial();
}
