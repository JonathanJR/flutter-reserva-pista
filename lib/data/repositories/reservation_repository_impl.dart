import '../../domain/models/reservation.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_datasource.dart';
import '../models/reservation_dto.dart';

/// Implementación del repositorio de reservas usando Firestore
class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource _remoteDataSource;

  const ReservationRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<Reservation>> getActiveReservationsStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _remoteDataSource
        .getActiveReservationsStream(startDate: startDate, endDate: endDate)
        .map(
          (reservationDtos) =>
              reservationDtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Reservation>> getUserReservationsStream(String userId) {
    return _remoteDataSource
        .getUserReservationsStream(userId)
        .map(
          (reservationDtos) =>
              reservationDtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Stream<List<Reservation>> getCourtReservationsStream(String courtId) {
    return _remoteDataSource
        .getCourtReservationsStream(courtId)
        .map(
          (reservationDtos) =>
              reservationDtos.map((dto) => dto.toDomain()).toList(),
        );
  }

  @override
  Future<String> createReservation({
    required String userId,
    required String courtId,
    required String courtName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Validaciones de negocio
    _validateReservationDates(startTime, endTime);

    // Crear DTO para la nueva reserva
    final reservationDto = ReservationDto.forCreation(
      userId: userId,
      courtId: courtId,
      courtName: courtName,
      startTime: startTime,
      endTime: endTime,
    );

    return await _remoteDataSource.createReservation(reservationDto);
  }

  @override
  Future<void> cancelReservation(String reservationId, String reason) async {
    if (reservationId.isEmpty) {
      throw ArgumentError('ID de reserva no puede estar vacío');
    }
    if (reason.isEmpty) {
      throw ArgumentError('Debe proporcionar una razón para la cancelación');
    }

    return await _remoteDataSource.cancelReservation(reservationId, reason);
  }

  @override
  Future<void> completeReservation(String reservationId) async {
    if (reservationId.isEmpty) {
      throw ArgumentError('ID de reserva no puede estar vacío');
    }

    return await _remoteDataSource.completeReservation(reservationId);
  }

  @override
  Future<Reservation?> getReservationById(String reservationId) async {
    if (reservationId.isEmpty) {
      throw ArgumentError('ID de reserva no puede estar vacío');
    }

    final reservationDto = await _remoteDataSource.getReservationById(
      reservationId,
    );
    return reservationDto?.toDomain();
  }

  @override
  Future<Map<String, int>> getUserReservationStats(String userId) async {
    if (userId.isEmpty) {
      throw ArgumentError('ID de usuario no puede estar vacío');
    }

    return await _remoteDataSource.getUserReservationStats(userId);
  }

  @override
  Future<int> cleanupOldReservations({int daysOld = 30}) async {
    if (daysOld < 1) {
      throw ArgumentError('Los días deben ser mayor a 0');
    }

    return await _remoteDataSource.cleanupOldReservations(daysOld: daysOld);
  }

  /// Validar fechas de reserva
  void _validateReservationDates(DateTime startTime, DateTime endTime) {
    final now = DateTime.now();

    // La reserva debe ser en el futuro
    if (startTime.isBefore(now)) {
      throw ArgumentError('La reserva debe ser para una fecha futura');
    }

    // La fecha de fin debe ser posterior a la de inicio
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      throw ArgumentError(
        'La hora de fin debe ser posterior a la hora de inicio',
      );
    }

    // Duración mínima (ejemplo: 30 minutos)
    const minDurationMinutes = 30;
    final durationMinutes = endTime.difference(startTime).inMinutes;
    if (durationMinutes < minDurationMinutes) {
      throw ArgumentError(
        'La reserva debe tener una duración mínima de $minDurationMinutes minutos',
      );
    }

    // Duración máxima (ejemplo: 3 horas)
    const maxDurationMinutes = 180;
    if (durationMinutes > maxDurationMinutes) {
      throw ArgumentError(
        'La reserva no puede exceder $maxDurationMinutes minutos',
      );
    }

    // No permitir reservas con más de X días de anticipación (ejemplo: 30 días)
    const maxDaysInAdvance = 30;
    final daysInAdvance = startTime.difference(now).inDays;
    if (daysInAdvance > maxDaysInAdvance) {
      throw ArgumentError(
        'No se pueden hacer reservas con más de $maxDaysInAdvance días de anticipación',
      );
    }
  }
}
