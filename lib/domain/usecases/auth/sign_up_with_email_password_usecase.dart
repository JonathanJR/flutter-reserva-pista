import '../../models/user.dart';
import '../../repositories/auth_repository.dart';

/// Use case para registrar un usuario con email y contraseña
class SignUpWithEmailPasswordUseCase {
  final AuthRepository _authRepository;

  const SignUpWithEmailPasswordUseCase(this._authRepository);

  Future<User> execute({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _authRepository.signUpWithEmailAndPassword(
      fullName: fullName,
      email: email,
      password: password,
    );
  }
}
