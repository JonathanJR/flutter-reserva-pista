import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_core/state_management.dart';

class CalendarState extends Equatable {
  final ValueState<bool> isUserLogged;

  const CalendarState({
    required this.isUserLogged,
  });

  factory CalendarState.initial() {
    return CalendarState(
      isUserLogged: ValueState.init(),
    );
  }

  @override
  List<Object?> get props => [isUserLogged];
}
