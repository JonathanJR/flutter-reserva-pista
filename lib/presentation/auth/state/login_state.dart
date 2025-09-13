import 'package:equatable/equatable.dart';
import '../../../domain/models/user.dart';

/// Estado de la pantalla de Login
class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const LoginState({
    required this.email,
    required this.password,
    required this.isLoading,
    this.errorMessage,
    this.user,
  });

  // TODO> Cambiar valores por defecto para pruebas
  factory LoginState.initial() {
    return const LoginState(
      email: 'yonigilena@gmail.com',
      password: '123456',
      isLoading: false,
      errorMessage: null,
      user: null,
    );
  }

  /// Validar si el email es válido
  bool get isEmailValid {
    return email.isNotEmpty && 
           email.contains('@') && 
           email.contains('.');
  }

  /// Validar si la contraseña es válida (mínimo 6 caracteres)
  bool get isPasswordValid {
    return password.length >= 6;
  }

  /// Validar si el formulario es válido
  bool get isFormValid {
    return isEmailValid && isPasswordValid && !isLoading;
  }

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [email, password, isLoading, errorMessage, user];
}
