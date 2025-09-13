import 'package:equatable/equatable.dart';

/// Estado de la pantalla de Perfil
class ProfileState extends Equatable {
  final bool isLoggedIn;
  final bool isLoading;
  final String? userEmail;
  final String? userName;
  final String? errorMessage;

  const ProfileState({
    required this.isLoggedIn,
    required this.isLoading,
    this.userEmail,
    this.userName,
    this.errorMessage,
  });

  factory ProfileState.initial() {
    return const ProfileState(
      isLoggedIn: false,
      isLoading: false,
      userEmail: null,
      userName: null,
      errorMessage: null,
    );
  }

  factory ProfileState.loading() {
    return const ProfileState(
      isLoggedIn: false,
      isLoading: true,
      userEmail: null,
      userName: null,
      errorMessage: null,
    );
  }

  factory ProfileState.loggedIn({
    required String email,
    required String name,
  }) {
    return ProfileState(
      isLoggedIn: true,
      isLoading: false,
      userEmail: email,
      userName: name,
      errorMessage: null,
    );
  }

  factory ProfileState.error(String message) {
    return ProfileState(
      isLoggedIn: false,
      isLoading: false,
      userEmail: null,
      userName: null,
      errorMessage: message,
    );
  }

  ProfileState copyWith({
    bool? isLoggedIn,
    bool? isLoading,
    String? userEmail,
    String? userName,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoggedIn,
    isLoading,
    userEmail,
    userName,
    errorMessage,
  ];
}
