import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_core/state_management.dart';

class RmtvState extends Equatable {
  final ValueState<bool> isUserLogged;

  const RmtvState({
    required this.isUserLogged,
  });

  factory RmtvState.initial() {
    return RmtvState(
      isUserLogged: ValueState.init(),
    );
  }

  @override
  List<Object?> get props => [isUserLogged];
}
