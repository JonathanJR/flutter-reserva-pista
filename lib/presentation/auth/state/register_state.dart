import 'package:equatable/equatable.dart';
import '../../../domain/models/user.dart';

/// Estado de la pantalla de Registro
class RegisterState extends Equatable {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final bool acceptTerms;
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const RegisterState({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.acceptTerms,
    required this.isLoading,
    this.errorMessage,
    this.user,
  });

  factory RegisterState.initial() {
    return const RegisterState(
      fullName: '',
      email: '',
      password: '',
      confirmPassword: '',
      acceptTerms: false,
      isLoading: false,
      errorMessage: null,
      user: null,
    );
  }

  /// Validar si el nombre completo es válido
  bool get isFullNameValid {
    return fullName.trim().length >= 2;
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

  /// Validar si la confirmación de contraseña coincide
  bool get isConfirmPasswordValid {
    return confirmPassword.length >= 6 && 
           password == confirmPassword;
  }

  /// Validar si el formulario es válido
  bool get isFormValid {
    return isFullNameValid && 
           isEmailValid && 
           isPasswordValid && 
           isConfirmPasswordValid &&
           acceptTerms && 
           !isLoading;
  }

  RegisterState copyWith({
    String? fullName,
    String? email,
    String? password,
    String? confirmPassword,
    bool? acceptTerms,
    bool? isLoading,
    String? errorMessage,
    User? user,
  }) {
    return RegisterState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      acceptTerms: acceptTerms ?? this.acceptTerms,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
    fullName, 
    email, 
    password, 
    confirmPassword, 
    acceptTerms, 
    isLoading, 
    errorMessage, 
    user
  ];
}
