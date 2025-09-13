import '../../models/user.dart';
import '../../repositories/auth_repository.dart';

/// Use case para iniciar sesión con email y contraseña
class SignInWithEmailPasswordUseCase {
  final AuthRepository _authRepository;

  const SignInWithEmailPasswordUseCase(this._authRepository);

  Future<User> execute({
    required String email,
    required String password,
  }) {
    return _authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
