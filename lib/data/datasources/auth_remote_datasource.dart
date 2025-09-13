import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user.dart';

/// Datasource remoto para autenticación con Firebase
class AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  const AuthRemoteDataSource(this._firebaseAuth, this._firestore);

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

      return await _getUserWithFirestoreData(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  /// Registrar usuario con email y contraseña
  Future<User> signUpWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      // Actualizar el displayName en Firebase Auth
      await credential.user!.updateDisplayName(fullName);

      // Crear documento del usuario en Firestore
      final now = DateTime.now();
      final userFirestore = {
        'id': credential.user!.uid,
        'fullName': fullName,
        'email': email,
        'registrationDate': now.millisecondsSinceEpoch,
        'active': true,
        'reservationCount': 0,
      };

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userFirestore);

      return User(
        id: credential.user!.uid,
        email: email,
        displayName: fullName,
        fullName: fullName,
        registrationDate: now,
        isActive: true,
        reservationCount: 0,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw Exception('Error al crear el usuario: ${e.toString()}');
    }
  }

  /// Obtener el usuario actual
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    return await _getUserWithFirestoreData(firebaseUser);
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Stream del usuario actual
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserWithFirestoreData(firebaseUser);
    });
  }

  /// Obtener usuario con datos de Firestore
  Future<User> _getUserWithFirestoreData(firebase_auth.User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          fullName: data['fullName'] ?? '',
          registrationDate: DateTime.fromMillisecondsSinceEpoch(
            data['registrationDate'] ?? 0
          ),
          isActive: data['active'] ?? true,
          reservationCount: data['reservationCount'] ?? 0,
        );
      } else {
        // Fallback si no existe el documento en Firestore
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          fullName: firebaseUser.displayName ?? '',
          registrationDate: DateTime.now(),
          isActive: true,
          reservationCount: 0,
        );
      }
    } catch (e) {
      // Fallback en caso de error
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        fullName: firebaseUser.displayName ?? '',
        registrationDate: DateTime.now(),
        isActive: true,
        reservationCount: 0,
      );
    }
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
