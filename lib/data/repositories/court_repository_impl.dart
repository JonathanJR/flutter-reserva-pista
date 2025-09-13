import '../../domain/models/court.dart';
import '../../domain/models/sport_type.dart';
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
        .map((courtDtos) => courtDtos
            .where((dto) => dto.available) // Solo pistas disponibles
            .map((dto) => dto.toDomain())
            .toList());
  }
  
  @override
  Stream<List<SportTypeInfo>> getSportTypesStream() {
    return _remoteDataSource.getCourtsStream()
        .map(_groupCourtsBySportType);
  }

  /// Agrupar courts por tipo de deporte y determinar disponibilidad
  List<SportTypeInfo> _groupCourtsBySportType(List<dynamic> courtDtos) {
    // Convertir a lista tipada
    final typedCourtDtos = courtDtos.cast<dynamic>();
    
    // Agrupar por courtType
    final Map<String, List<dynamic>> courtsByType = {};
    for (final courtDto in typedCourtDtos) {
      final courtType = courtDto.courtType;
      if (!courtsByType.containsKey(courtType)) {
        courtsByType[courtType] = [];
      }
      courtsByType[courtType]!.add(courtDto);
    }

    // Crear SportTypeInfo para cada tipo
    return SportType.values.map((sportType) {
      final courts = courtsByType[sportType.id] ?? [];
      final isAvailable = courts.any((court) => court.available);
      
      return SportTypeInfo.fromSportType(
        sportType,
        isAvailable: isAvailable,
      );
    }).toList();
  }
}
