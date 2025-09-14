import '../../models/reservation.dart';
import '../../models/reservation_status.dart';
import '../../repositories/reservation_repository.dart';
import '../../services/reservation_business_rules.dart';
import 'create_reservation_usecase.dart';

/// Caso de uso para cancelar una reserva existente con validaciones robustas
class CancelReservationUseCase {
  final ReservationRepository _reservationRepository;
  final ReservationBusinessRules _businessRules;

  const CancelReservationUseCase(
    this._reservationRepository,
    this._businessRules,
  );

  /// Ejecutar cancelación de reserva con validaciones completas
  Future<void> execute({
    required String reservationId,
    required String userId,
    required String reason,
  }) async {
    // Verificar que la reserva existe
    final reservation = await _reservationRepository.getReservationById(
      reservationId,
    );

    if (reservation == null) {
      throw ReservationNotFoundException('La reserva no existe');
    }

    // Verificar permisos del usuario
    if (reservation.userId != userId) {
      throw ReservationPermissionException(
        'No tienes permisos para cancelar esta reserva',
      );
    }

    // Validar reglas de negocio para cancelación
    final validationResult = _businessRules.validateReservationCancellation(
      reservation: reservation,
      currentTime: DateTime.now(),
    );

    if (!validationResult.isValid) {
      throw ReservationValidationException(
        validationResult.errorMessage!,
        validationResult.errorCode!,
      );
    }

    try {
      // Cancelar la reserva
      await _reservationRepository.cancelReservation(reservationId, reason);
    } catch (e) {
      throw ReservationCancellationException(
        'Error al cancelar la reserva: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Verificar si una reserva se puede cancelar sin hacer la cancelación
  Future<CancellationEligibility> checkCancellationEligibility({
    required String reservationId,
    required String userId,
  }) async {
    final reservation = await _reservationRepository.getReservationById(
      reservationId,
    );

    if (reservation == null) {
      return CancellationEligibility(
        canCancel: false,
        reason: 'La reserva no existe',
        errorCode: ReservationError.unknown,
      );
    }

    if (reservation.userId != userId) {
      return CancellationEligibility(
        canCancel: false,
        reason: 'No tienes permisos para cancelar esta reserva',
        errorCode: ReservationError.userNotFound,
      );
    }

    final validationResult = _businessRules.validateReservationCancellation(
      reservation: reservation,
      currentTime: DateTime.now(),
    );

    return CancellationEligibility(
      canCancel: validationResult.isValid,
      reason: validationResult.errorMessage,
      errorCode: validationResult.errorCode,
      reservation: reservation,
    );
  }

  /// Obtener información de cancelación para mostrar al usuario
  Future<CancellationInfo> getCancellationInfo(String reservationId) async {
    final reservation = await _reservationRepository.getReservationById(
      reservationId,
    );

    if (reservation == null) {
      throw ReservationNotFoundException('La reserva no existe');
    }

    final now = DateTime.now();
    final timeUntilStart = reservation.startTime.difference(now);
    const minimumCancellationHours = 2;
    final minimumCancellationTime = reservation.startTime.subtract(
      const Duration(hours: minimumCancellationHours),
    );

    final canCancel =
        now.isBefore(minimumCancellationTime) &&
        reservation.status == ReservationStatus.confirmed;

    return CancellationInfo(
      reservation: reservation,
      canCancel: canCancel,
      timeUntilStart: timeUntilStart,
      hoursUntilCancellationDeadline: canCancel
          ? minimumCancellationTime.difference(now).inHours
          : 0,
      cancellationDeadline: minimumCancellationTime,
    );
  }
}

/// Información sobre la elegibilidad de cancelación
class CancellationEligibility {
  final bool canCancel;
  final String? reason;
  final ReservationError? errorCode;
  final Reservation? reservation;

  const CancellationEligibility({
    required this.canCancel,
    this.reason,
    this.errorCode,
    this.reservation,
  });

  /// Mensaje localizado para mostrar al usuario
  String get localizedMessage {
    if (canCancel) return 'Esta reserva se puede cancelar';
    if (reason != null) return reason!;
    return 'No se puede cancelar esta reserva';
  }
}

/// Información detallada sobre cancelación
class CancellationInfo {
  final Reservation reservation;
  final bool canCancel;
  final Duration timeUntilStart;
  final int hoursUntilCancellationDeadline;
  final DateTime cancellationDeadline;

  const CancellationInfo({
    required this.reservation,
    required this.canCancel,
    required this.timeUntilStart,
    required this.hoursUntilCancellationDeadline,
    required this.cancellationDeadline,
  });

  /// Formatear tiempo hasta la fecha límite de cancelación
  String get formattedTimeUntilDeadline {
    if (!canCancel) return '';

    if (hoursUntilCancellationDeadline < 1) {
      final minutes = (hoursUntilCancellationDeadline * 60).round();
      return '$minutes minutos';
    }

    return '$hoursUntilCancellationDeadline horas';
  }

  /// Mensaje descriptivo para el usuario
  String get cancellationMessage {
    if (canCancel) {
      return 'Puedes cancelar esta reserva hasta $formattedTimeUntilDeadline antes del horario programado';
    } else {
      return 'Ya no se puede cancelar esta reserva (debe cancelarse al menos 2 horas antes)';
    }
  }
}

/// Excepciones específicas para cancelación de reservas
class ReservationNotFoundException implements Exception {
  final String message;
  const ReservationNotFoundException(this.message);

  @override
  String toString() => 'ReservationNotFoundException: $message';
}

class ReservationPermissionException implements Exception {
  final String message;
  const ReservationPermissionException(this.message);

  @override
  String toString() => 'ReservationPermissionException: $message';
}

class ReservationCancellationException implements Exception {
  final String message;
  final Object? originalError;

  const ReservationCancellationException(this.message, {this.originalError});

  @override
  String toString() => 'ReservationCancellationException: $message';
}
