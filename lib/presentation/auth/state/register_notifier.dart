import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../domain/usecases/auth/sign_up_with_email_password_usecase.dart';
import 'register_state.dart';

/// Notifier para manejar el estado de registro
class RegisterNotifier extends StateNotifier<RegisterState> {
  final SignUpWithEmailPasswordUseCase _signUpUseCase;

  RegisterNotifier(this._signUpUseCase) : super(RegisterState.initial());

  /// Actualizar nombre completo
  void updateFullName(String fullName) {
    state = state.copyWith(
      fullName: fullName,
      errorMessage: null, // Limpiar error al escribir
    );
  }

  /// Actualizar email
  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      errorMessage: null, // Limpiar error al escribir
    );
  }

  /// Actualizar contraseña
  void updatePassword(String password) {
    state = state.copyWith(
      password: password,
      errorMessage: null, // Limpiar error al escribir
    );
  }

  /// Actualizar confirmación de contraseña
  void updateConfirmPassword(String confirmPassword) {
    state = state.copyWith(
      confirmPassword: confirmPassword,
      errorMessage: null, // Limpiar error al escribir
    );
  }

  /// Actualizar aceptación de términos
  void updateAcceptTerms(bool acceptTerms) {
    state = state.copyWith(
      acceptTerms: acceptTerms,
      errorMessage: null, // Limpiar error al escribir
    );
  }

  /// Registrar usuario
  Future<void> signUp() async {
    if (!state.isFormValid) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final user = await _signUpUseCase.execute(
        fullName: state.fullName.trim(),
        email: state.email.trim(),
        password: state.password,
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

/// Provider para el RegisterNotifier
final registerNotifierProvider = StateNotifierProvider<RegisterNotifier, RegisterState>((ref) {
  final signUpUseCase = ref.read(signUpWithEmailPasswordUseCaseProvider);
  return RegisterNotifier(signUpUseCase);
});
