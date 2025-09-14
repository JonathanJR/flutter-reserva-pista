import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/court_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/remote_config_datasource.dart';
import '../../data/repositories/court_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/remote_config_repository_impl.dart';
import '../../domain/repositories/court_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/remote_config_repository.dart';
import '../../domain/usecases/get_sport_types_stream_usecase.dart';
import '../../domain/usecases/get_courts_by_sport_type_usecase.dart';
import '../../domain/usecases/get_available_dates_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_email_password_usecase.dart';
import '../../domain/usecases/auth/sign_up_with_email_password_usecase.dart';

/// Provider para FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para FirebaseAuth
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Provider para FirebaseRemoteConfig
final firebaseRemoteConfigProvider = Provider<FirebaseRemoteConfig>((ref) {
  return FirebaseRemoteConfig.instance;
});

/// Provider para CourtRemoteDataSource
final courtRemoteDataSourceProvider = Provider<CourtRemoteDataSource>((ref) {
  final firestore = ref.read(firestoreProvider);
  return CourtRemoteDataSource(firestore);
});

/// Provider para AuthRemoteDataSource
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  final firestore = ref.read(firestoreProvider);
  return AuthRemoteDataSource(firebaseAuth, firestore);
});

/// Provider para RemoteConfigDataSource
final remoteConfigDataSourceProvider = Provider<RemoteConfigDataSource>((ref) {
  final remoteConfig = ref.read(firebaseRemoteConfigProvider);
  return RemoteConfigDataSource(remoteConfig);
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

/// Provider para RemoteConfigRepository
final remoteConfigRepositoryProvider = Provider<RemoteConfigRepository>((ref) {
  final dataSource = ref.read(remoteConfigDataSourceProvider);
  return RemoteConfigRepositoryImpl(dataSource);
});

/// Provider para GetSportTypesStreamUseCase (tiempo real)
final getSportTypesStreamUseCaseProvider = Provider<GetSportTypesStreamUseCase>((ref) {
  final repository = ref.read(courtRepositoryProvider);
  return GetSportTypesStreamUseCase(repository);
});

/// Provider para GetCourtsBySportTypeUseCase
final getCourtsBySportTypeUseCaseProvider = Provider<GetCourtsBySportTypeUseCase>((ref) {
  final repository = ref.read(courtRepositoryProvider);
  return GetCourtsBySportTypeUseCase(repository);
});

/// Provider para GetAvailableDatesUseCase
final getAvailableDatesUseCaseProvider = Provider<GetAvailableDatesUseCase>((ref) {
  final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
  return GetAvailableDatesUseCase(remoteConfigRepository);
});

/// Provider para SignInWithEmailPasswordUseCase
final signInWithEmailPasswordUseCaseProvider = Provider<SignInWithEmailPasswordUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignInWithEmailPasswordUseCase(repository);
});

/// Provider para SignUpWithEmailPasswordUseCase
final signUpWithEmailPasswordUseCaseProvider = Provider<SignUpWithEmailPasswordUseCase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return SignUpWithEmailPasswordUseCase(repository);
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

/// Provider para obtener pistas por sport type
final courtsBySportTypeProvider = StreamProvider.family<List<dynamic>, String>((ref, sportType) {
  final useCase = ref.read(getCourtsBySportTypeUseCaseProvider);
  return useCase.execute(sportType);
});
