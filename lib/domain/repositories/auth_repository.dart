import '../models/user.dart';

/// Repository para operaciones de autenticación
abstract interface class AuthRepository {
  /// Iniciar sesión con email y contraseña
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registrar usuario con email y contraseña
  Future<User> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  });

  /// Obtener el usuario actual
  Future<User?> getCurrentUser();

  /// Cerrar sesión
  Future<void> signOut();

  /// Stream del usuario actual
  Stream<User?> get authStateChanges;
}
