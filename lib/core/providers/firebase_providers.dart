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
import '../../domain/usecases/get_time_slots_usecase.dart';
import '../../domain/usecases/get_time_slots_with_availability_usecase.dart';
import '../../domain/usecases/auth/sign_in_with_email_password_usecase.dart';
import '../../domain/usecases/auth/sign_up_with_email_password_usecase.dart';
import '../../data/datasources/reservation_remote_datasource.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../../domain/usecases/reservation/create_reservation_usecase.dart';
import '../../domain/usecases/reservation/cancel_reservation_usecase.dart';
import '../../domain/usecases/reservation/get_reservations_usecase.dart';
import '../../domain/services/reservation_business_rules.dart';

// Re-export reservation providers para facilitar importaciones
export 'reservation_providers.dart';

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
final getSportTypesStreamUseCaseProvider = Provider<GetSportTypesStreamUseCase>(
  (ref) {
    final repository = ref.read(courtRepositoryProvider);
    return GetSportTypesStreamUseCase(repository);
  },
);

/// Provider para GetCourtsBySportTypeUseCase
final getCourtsBySportTypeUseCaseProvider =
    Provider<GetCourtsBySportTypeUseCase>((ref) {
      final repository = ref.read(courtRepositoryProvider);
      return GetCourtsBySportTypeUseCase(repository);
    });

/// Provider para GetAvailableDatesUseCase
final getAvailableDatesUseCaseProvider = Provider<GetAvailableDatesUseCase>((
  ref,
) {
  final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
  return GetAvailableDatesUseCase(remoteConfigRepository);
});

/// Provider para GetTimeSlotsUseCase
final getTimeSlotsUseCaseProvider = Provider<GetTimeSlotsUseCase>((ref) {
  final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
  return GetTimeSlotsUseCase(remoteConfigRepository);
});

/// Provider para GetTimeSlotsWithAvailabilityUseCase (integrado con cache)
final getTimeSlotsWithAvailabilityUseCaseProvider =
    Provider<GetTimeSlotsWithAvailabilityUseCase>((ref) {
      final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
      return GetTimeSlotsWithAvailabilityUseCase(remoteConfigRepository);
    });

/// Provider para SignInWithEmailPasswordUseCase
final signInWithEmailPasswordUseCaseProvider =
    Provider<SignInWithEmailPasswordUseCase>((ref) {
      final repository = ref.read(authRepositoryProvider);
      return SignInWithEmailPasswordUseCase(repository);
    });

/// Provider para SignUpWithEmailPasswordUseCase
final signUpWithEmailPasswordUseCaseProvider =
    Provider<SignUpWithEmailPasswordUseCase>((ref) {
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
final courtsBySportTypeProvider = StreamProvider.family<List<dynamic>, String>((
  ref,
  sportType,
) {
  final useCase = ref.read(getCourtsBySportTypeUseCaseProvider);
  return useCase.execute(sportType);
});

// ========================================
// PROVIDERS PARA RESERVAS
// ========================================

/// Provider para ReservationRemoteDataSource
final reservationRemoteDataSourceProvider =
    Provider<ReservationRemoteDataSource>((ref) {
      final firestore = ref.read(firestoreProvider);
      return ReservationRemoteDataSource(firestore);
    });

/// Provider para ReservationRepository
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final remoteDataSource = ref.read(reservationRemoteDataSourceProvider);
  return ReservationRepositoryImpl(remoteDataSource);
});

/// Provider para ReservationBusinessRules
final reservationBusinessRulesProvider = Provider<ReservationBusinessRules>((
  ref,
) {
  final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
  return ReservationBusinessRules(remoteConfigRepository);
});

/// Provider para CreateReservationUseCase con reglas de negocio
final createReservationUseCaseProvider = Provider<CreateReservationUseCase>((
  ref,
) {
  final repository = ref.read(reservationRepositoryProvider);
  final businessRules = ref.read(reservationBusinessRulesProvider);
  return CreateReservationUseCase(repository, businessRules);
});

/// Provider para CancelReservationUseCase con reglas de negocio
final cancelReservationUseCaseProvider = Provider<CancelReservationUseCase>((
  ref,
) {
  final repository = ref.read(reservationRepositoryProvider);
  final businessRules = ref.read(reservationBusinessRulesProvider);
  return CancelReservationUseCase(repository, businessRules);
});

/// Provider para GetReservationsUseCase
final getReservationsUseCaseProvider = Provider<GetReservationsUseCase>((ref) {
  final repository = ref.read(reservationRepositoryProvider);
  return GetReservationsUseCase(repository);
});
