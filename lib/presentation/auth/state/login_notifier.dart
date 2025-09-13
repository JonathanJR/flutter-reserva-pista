import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../domain/usecases/auth/sign_in_with_email_password_usecase.dart';
import 'login_state.dart';

/// Notifier para manejar el estado de login
class LoginNotifier extends StateNotifier<LoginState> {
  final SignInWithEmailPasswordUseCase _signInUseCase;

  LoginNotifier(this._signInUseCase) : super(LoginState.initial());

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

  /// Iniciar sesión
  Future<void> signIn() async {
    if (!state.isFormValid) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final user = await _signInUseCase.execute(
        email: state.email,
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

/// Provider para el LoginNotifier
final loginNotifierProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final signInUseCase = ref.read(signInWithEmailPasswordUseCaseProvider);
  return LoginNotifier(signInUseCase);
});
