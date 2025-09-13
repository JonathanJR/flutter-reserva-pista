import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';

class HomeState extends Equatable {
  final ValueState<bool> isUserLogged;
  final ValueState<List<MatchFan>> matches; 


  const HomeState({
    required this.isUserLogged,
    required this.matches,

  });

  factory HomeState.initial() {
    return HomeState(
      isUserLogged: ValueState.init(),
      matches: ValueState.init()
  
    );
  }
  HomeState copyWith({
    ValueState<bool>? isUserLogged,
    ValueState<List<MatchFan>>? matches,
  }) {
    return HomeState(
      isUserLogged: isUserLogged ?? this.isUserLogged,
      matches: matches ?? this.matches,
    );
  }

  @override
  List<Object?> get props => [isUserLogged,matches];
}