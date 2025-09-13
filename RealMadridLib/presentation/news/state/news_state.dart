import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_core/state_management.dart';

class NewsState extends Equatable {
  final ValueState<bool> isUserLogged;

  const NewsState({
    required this.isUserLogged,
  });

  factory NewsState.initial() {
    return NewsState(
      isUserLogged: ValueState.init(),
    );
  }

  @override
  List<Object?> get props => [isUserLogged];
}
