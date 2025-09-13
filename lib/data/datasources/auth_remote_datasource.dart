import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/models/user.dart';

/// Datasource remoto para autenticación con Firebase
class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  const AuthRemoteDataSource(this._firebaseAuth);

  /// Iniciar sesión con email y contraseña
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('No se pudo autenticar al usuario');
      }

      return _mapFirebaseUserToDomain(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Obtener el usuario actual
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    return _mapFirebaseUserToDomain(firebaseUser);
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Stream del usuario actual
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _mapFirebaseUserToDomain(firebaseUser);
    });
  }

  /// Mapear FirebaseUser a User de dominio
  User _mapFirebaseUserToDomain(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
    );
  }

  /// Mapear excepciones de Firebase Auth
  Exception _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No existe una cuenta con este email');
      case 'wrong-password':
        return Exception('Contraseña incorrecta');
      case 'invalid-email':
        return Exception('Email inválido');
      case 'user-disabled':
        return Exception('Esta cuenta ha sido deshabilitada');
      case 'too-many-requests':
        return Exception('Demasiados intentos fallidos. Intenta más tarde');
      case 'invalid-credential':
        return Exception('Credenciales inválidas');
      default:
        return Exception('Error de autenticación: ${e.message}');
    }
  }
}
