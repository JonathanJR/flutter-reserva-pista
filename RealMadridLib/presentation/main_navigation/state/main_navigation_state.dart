import 'package:rm_app_flutter_core/state_management.dart';

class MainNavigationState extends Equatable {
  final int index;

  const MainNavigationState(this.index);

  factory MainNavigationState.initial() => const MainNavigationState(0);

  MainNavigationState copyWith({
    int? index,
  }) {
    return MainNavigationState(
      index ?? this.index,
    );
  }

  @override
  List<Object?> get props => [index];
}
