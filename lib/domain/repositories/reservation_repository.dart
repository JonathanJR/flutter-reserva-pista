import '../models/reservation.dart';

/// Repositorio abstracto para el manejo de reservas
abstract interface class ReservationRepository {
  /// Obtener todas las reservas activas en un rango de fechas
  /// Útil para el cache global y mostrar disponibilidad
  Stream<List<Reservation>> getActiveReservationsStream({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtener reservas de un usuario específico
  Stream<List<Reservation>> getUserReservationsStream(String userId);

  /// Obtener reservas de una pista específica
  Stream<List<Reservation>> getCourtReservationsStream(String courtId);

  /// Crear una nueva reserva
  Future<String> createReservation({
    required String userId,
    required String courtId,
    required String courtName,
    required DateTime startTime,
    required DateTime endTime,
  });

  /// Cancelar una reserva existente
  Future<void> cancelReservation(String reservationId, String reason);

  /// Marcar una reserva como completada
  Future<void> completeReservation(String reservationId);

  /// Obtener una reserva específica por ID
  Future<Reservation?> getReservationById(String reservationId);

  /// Obtener estadísticas de reservas de un usuario
  Future<Map<String, int>> getUserReservationStats(String userId);

  /// Limpiar reservas antiguas (para mantenimiento)
  Future<int> cleanupOldReservations({int daysOld = 30});
}
