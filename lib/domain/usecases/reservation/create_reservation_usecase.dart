import '../../repositories/reservation_repository.dart';
import '../../services/reservation_business_rules.dart';

/// Caso de uso para crear una nueva reserva con validaciones robustas
class CreateReservationUseCase {
  final ReservationRepository _reservationRepository;
  final ReservationBusinessRules _businessRules;

  const CreateReservationUseCase(
    this._reservationRepository,
    this._businessRules,
  );

  /// Ejecutar creación de reserva con validaciones completas
  Future<String> execute({
    required String userId,
    required String courtId,
    required String courtName,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? userProfile,
  }) async {
    // Obtener reservas existentes para validaciones
    final existingReservations = await _reservationRepository
        .getActiveReservationsStream(
          startDate: startTime.subtract(const Duration(days: 1)),
          endDate: endTime.add(const Duration(days: 1)),
        )
        .first;

    // Validar reglas de negocio
    final validationResult = await _businessRules.validateReservationCreation(
      userId: userId,
      courtId: courtId,
      startTime: startTime,
      endTime: endTime,
      existingReservations: existingReservations,
      userProfile: userProfile,
    );

    if (!validationResult.isValid) {
      throw ReservationValidationException(
        validationResult.errorMessage!,
        validationResult.errorCode!,
      );
    }

    try {
      // Crear la reserva usando la interfaz del repository
      final reservationId = await _reservationRepository.createReservation(
        userId: userId,
        courtId: courtId,
        courtName: courtName,
        startTime: startTime,
        endTime: endTime,
      );

      return reservationId;
    } catch (e) {
      // Re-lanzar con contexto adicional
      throw ReservationCreationException(
        'Error al crear la reserva en la base de datos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Obtener restricciones del usuario antes de crear reserva
  Future<UserRestrictions> getUserRestrictions(String userId) async {
    final userReservations = await _reservationRepository
        .getUserReservationsStream(userId)
        .first;

    return _businessRules.getUserRestrictions(
      userId: userId,
      userReservations: userReservations,
    );
  }

  /// Verificar disponibilidad de un slot específico
  Future<bool> checkSlotAvailability({
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final existingReservations = await _reservationRepository
        .getActiveReservationsStream(
          startDate: startTime.subtract(const Duration(hours: 1)),
          endDate: endTime.add(const Duration(hours: 1)),
        )
        .first;

    final validationResult = _businessRules.validateSlotAvailability(
      courtId,
      startTime,
      endTime,
      existingReservations,
    );

    return validationResult.isValid;
  }
}

/// Excepción específica para errores de validación de reservas
class ReservationValidationException implements Exception {
  final String message;
  final ReservationError errorCode;

  const ReservationValidationException(this.message, this.errorCode);

  @override
  String toString() => 'ReservationValidationException: $message';

  /// Obtener mensaje de error localizado
  String get localizedMessage {
    switch (errorCode) {
      case ReservationError.pastTime:
        return 'No puedes reservar en el pasado';
      case ReservationError.slotOccupied:
        return 'Este horario ya está ocupado';
      case ReservationError.maxActiveReservationsReached:
        return 'Has alcanzado el límite de reservas activas';
      case ReservationError.maxDailyReservationsReached:
        return 'Solo puedes hacer una reserva por día';
      case ReservationError.outsideOperatingHours:
        return 'Fuera del horario de operación (8:00 - 22:00)';
      case ReservationError.tooFarInAdvance:
        return 'No puedes reservar tan adelante';
      case ReservationError.durationTooShort:
        return 'La duración mínima es de 90 minutos';
      case ReservationError.durationTooLong:
        return 'La duración máxima es de 3 horas';
      default:
        return message;
    }
  }

  /// Obtener icono para el tipo de error
  String get errorIcon {
    switch (errorCode) {
      case ReservationError.pastTime:
        return '⏰';
      case ReservationError.slotOccupied:
        return '🚫';
      case ReservationError.maxActiveReservationsReached:
      case ReservationError.maxDailyReservationsReached:
        return '📊';
      case ReservationError.outsideOperatingHours:
        return '🕐';
      case ReservationError.tooFarInAdvance:
        return '📅';
      case ReservationError.durationTooShort:
      case ReservationError.durationTooLong:
        return '⏱️';
      default:
        return '❌';
    }
  }
}

/// Excepción para errores durante la creación de reservas
class ReservationCreationException implements Exception {
  final String message;
  final Object? originalError;

  const ReservationCreationException(this.message, {this.originalError});

  @override
  String toString() => 'ReservationCreationException: $message';
}
