import '../../models/reservation.dart';
import '../../repositories/reservation_repository.dart';

/// Caso de uso para obtener reservas con diferentes filtros
class GetReservationsUseCase {
  final ReservationRepository _reservationRepository;

  const GetReservationsUseCase(this._reservationRepository);

  /// Obtener todas las reservas activas en un rango de fechas
  /// Usado para el cache global de disponibilidad
  Stream<List<Reservation>> getActiveReservationsStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _reservationRepository.getActiveReservationsStream(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Obtener reservas de un usuario específico
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    if (userId.isEmpty) {
      throw ArgumentError('ID de usuario no puede estar vacío');
    }

    return _reservationRepository.getUserReservationsStream(userId);
  }

  /// Obtener reservas de una pista específica
  Stream<List<Reservation>> getCourtReservationsStream(String courtId) {
    if (courtId.isEmpty) {
      throw ArgumentError('ID de pista no puede estar vacío');
    }

    return _reservationRepository.getCourtReservationsStream(courtId);
  }

  /// Obtener estadísticas de reservas de un usuario
  Future<Map<String, int>> getUserReservationStats(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('ID de usuario no puede estar vacío');
    }

    return await _reservationRepository.getUserReservationStats(userId);
  }

  /// Obtener una reserva específica por ID
  Future<Reservation?> getReservationById(String reservationId) async {
    if (reservationId.isEmpty) {
      throw ArgumentError('ID de reserva no puede estar vacío');
    }

    return await _reservationRepository.getReservationById(reservationId);
  }
}
