import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/court_remote_datasource.dart';
import '../../data/repositories/court_repository_impl.dart';
import '../../domain/repositories/court_repository.dart';
import '../../domain/usecases/get_sport_types_stream_usecase.dart';

/// Provider para FirebaseFirestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para CourtRemoteDataSource
final courtRemoteDataSourceProvider = Provider<CourtRemoteDataSource>((ref) {
  final firestore = ref.read(firestoreProvider);
  return CourtRemoteDataSource(firestore);
});

/// Provider para CourtRepository
final courtRepositoryProvider = Provider<CourtRepository>((ref) {
  final remoteDataSource = ref.read(courtRemoteDataSourceProvider);
  return CourtRepositoryImpl(remoteDataSource);
});

/// Provider para GetSportTypesStreamUseCase (tiempo real)
final getSportTypesStreamUseCaseProvider = Provider<GetSportTypesStreamUseCase>((ref) {
  final repository = ref.read(courtRepositoryProvider);
  return GetSportTypesStreamUseCase(repository);
});

/// Provider para obtener los tipos de deporte con disponibilidad en tiempo real
final sportTypesProvider = StreamProvider((ref) {
  final useCase = ref.read(getSportTypesStreamUseCaseProvider);
  return useCase.execute();
});
