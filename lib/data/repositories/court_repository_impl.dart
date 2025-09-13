import '../../domain/models/court.dart';
import '../../domain/repositories/court_repository.dart';
import '../datasources/court_remote_datasource.dart';

/// Implementación del repositorio de courts usando Firestore
class CourtRepositoryImpl implements CourtRepository {
  final CourtRemoteDataSource _remoteDataSource;

  const CourtRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Court>> getCourtsStream() {
    return _remoteDataSource
        .getCourtsStream()
        .map((courtDtos) => courtDtos.map((dto) => dto.toDomain()).toList());
  }

  @override
  Stream<List<Court>> getCourtsBySportTypeStream(String sportType) {
    return _remoteDataSource
        .getCourtsBySportTypeStream(sportType)
        .map((courtDtos) => courtDtos.map((dto) => dto.toDomain()).toList());
  }
}
