import '../models/court.dart';
import '../repositories/court_repository.dart';

/// Use case para obtener pistas por tipo de deporte en tiempo real
class GetCourtsBySportTypeUseCase {
  final CourtRepository _repository;

  const GetCourtsBySportTypeUseCase(this._repository);

  /// Obtener stream de pistas por tipo de deporte
  Stream<List<Court>> execute(String sportType) {
    return _repository.getCourtsBySportTypeStream(sportType);
  }
}
