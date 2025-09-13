import '../models/sport_type.dart';
import '../repositories/court_repository.dart';

/// Caso de uso para obtener tipos de deporte con información de disponibilidad en tiempo real
class GetSportTypesStreamUseCase {
  final CourtRepository _courtRepository;

  const GetSportTypesStreamUseCase(this._courtRepository);

  /// Ejecuta el caso de uso como stream
  /// Retorna stream de SportTypeInfo con disponibilidad en tiempo real
  Stream<List<SportTypeInfo>> execute() async* {
    yield* _courtRepository.getCourtsStream().map((courts) {
      // Crear mapa de disponibilidad por tipo de deporte
      final availabilityMap = <String, bool>{};
      
      for (final sportType in SportType.values) {
        final hasAvailableCourts = courts.any(
          (court) => court.courtType == sportType.id && court.available,
        );
        availabilityMap[sportType.id] = hasAvailableCourts;
      }

      // Crear SportTypeInfo con disponibilidad real
      return SportType.values.map((sportType) {
        return SportTypeInfo.fromSportType(
          sportType,
          isAvailable: availabilityMap[sportType.id] ?? false,
        );
      }).toList();
    });
  }
}
