import '../models/court.dart';

/// Repositorio abstracto para manejo de courts
/// Seguimos el patrón Repository del dominio
abstract class CourtRepository {
  /// Stream en tiempo real de todas las courts
  Stream<List<Court>> getCourtsStream();

  /// Stream en tiempo real de courts por tipo de deporte
  Stream<List<Court>> getCourtsBySportTypeStream(String sportType);
}
