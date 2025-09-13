import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/court_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/court_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/court_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_sport_types_stream_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_email_password_usecase.dart';

/// Provider para FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider para CourtRemoteDataSource
final courtRemoteDataSourceProvider = Provider<CourtRemoteDataSource>((ref) {
  final firestore = ref.read(firestoreProvider);
  return CourtRemoteDataSource(firestore);
});

/// Provider para AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return AuthRemoteDataSource(firebaseAuth);
});

/// Provider para CourtRepository
final courtRepositoryProvider = Provider<CourtRepository>((ref) {
  final remoteDataSource = ref.read(courtRemoteDataSourceProvider);
  return CourtRepositoryImpl(remoteDataSource);
});

/// Provider para AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.read(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});

/// Provider para GetSportTypesStreamUseCase (tiempo real)
final getSportTypesStreamUseCaseProvider = Provider<GetSportTypesStreamUseCase>((ref) {
  final repository = ref.read(courtRepositoryProvider);
  return GetSportTypesStreamUseCase(repository);
});

/// Provider para SignInWithEmailPasswordUseCase
final signInWithEmailPasswordUseCaseProvider = Provider<SignInWithEmailPasswordUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignInWithEmailPasswordUseCase(repository);
});

/// Provider para obtener los tipos de deporte con disponibilidad en tiempo real
final sportTypesProvider = StreamProvider((ref) {
  final useCase = ref.read(getSportTypesStreamUseCaseProvider);
  return useCase.execute();
});

/// Provider para el estado de autenticación
final authStateProvider = StreamProvider((ref) {
  final repository = ref.read(authRepositoryProvider);
  return repository.authStateChanges;
});
