import 'package:equatable/equatable.dart';
import '../../../domain/models/sport_type.dart';

/// Estado de la pantalla Home
class HomeState extends Equatable {
  final bool isLoading;
  final List<SportTypeInfo> sports;
  final String? errorMessage;

  const HomeState({
    required this.isLoading,
    required this.sports,
    this.errorMessage,
  });

  factory HomeState.initial() {
    return const HomeState(
      isLoading: true,
      sports: [],
      errorMessage: null,
    );
  }

  factory HomeState.loading() {
    return const HomeState(
      isLoading: true,
      sports: [],
      errorMessage: null,
    );
  }

  factory HomeState.success(List<SportTypeInfo> sports) {
    return HomeState(
      isLoading: false,
      sports: sports,
      errorMessage: null,
    );
  }

  factory HomeState.error(String message) {
    return HomeState(
      isLoading: false,
      sports: [],
      errorMessage: message,
    );
  }

  HomeState copyWith({
    bool? isLoading,
    List<SportTypeInfo>? sports,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      sports: sports ?? this.sports,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, sports, errorMessage];
}
