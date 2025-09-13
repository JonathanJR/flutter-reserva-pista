import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_core/state_management.dart';

class ShopState extends Equatable {
  final ValueState<bool> isUserLogged;

  const ShopState({
    required this.isUserLogged,
  });

  factory ShopState.initial() {
    return ShopState(
      isUserLogged: ValueState.init(),
    );
  }

  @override
  List<Object?> get props => [isUserLogged];
}
