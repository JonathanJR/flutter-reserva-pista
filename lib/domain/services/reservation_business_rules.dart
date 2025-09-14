import '../models/reservation.dart';
import '../models/reservation_status.dart';
import '../repositories/remote_config_repository.dart';

/// Servicio para validar reglas de negocio de reservas
class ReservationBusinessRules {
  final RemoteConfigRepository _remoteConfigRepository;

  const ReservationBusinessRules(this._remoteConfigRepository);

  /// Validar si una reserva se puede crear
  Future<BusinessRuleResult> validateReservationCreation({
    required String userId,
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Reservation> existingReservations,
    Map<String, dynamic>? userProfile,
  }) async {
    // Validación 1: Horarios básicos
    final basicValidation = _validateBasicTimeRules(startTime, endTime);
    if (!basicValidation.isValid) {
      return basicValidation;
    }

    // Validación 2: Horarios de operación
    final operatingHoursValidation = _validateOperatingHours(startTime);
    if (!operatingHoursValidation.isValid) {
      return operatingHoursValidation;
    }

    // Validación 3: Disponibilidad del slot
    final availabilityValidation = validateSlotAvailability(
      courtId,
      startTime,
      endTime,
      existingReservations,
    );
    if (!availabilityValidation.isValid) {
      return availabilityValidation;
    }

    // Validación 4: Límites por usuario
    final userLimitsValidation = _validateUserLimits(
      userId,
      startTime,
      existingReservations,
      userProfile,
    );
    if (!userLimitsValidation.isValid) {
      return userLimitsValidation;
    }

    // Validación 5: Política de anticipación
    final advanceValidation = _validateAdvanceBookingPolicy(startTime);
    if (!advanceValidation.isValid) {
      return advanceValidation;
    }

    return BusinessRuleResult.success();
  }

  /// Validar si una reserva se puede cancelar
  BusinessRuleResult validateReservationCancellation({
    required Reservation reservation,
    required DateTime currentTime,
  }) {
    // No se puede cancelar si ya está cancelada
    if (reservation.status == ReservationStatus.cancelled) {
      return BusinessRuleResult.failure(
        'Esta reserva ya ha sido cancelada',
        ReservationError.alreadyCancelled,
      );
    }

    // No se puede cancelar si ya está completada
    if (reservation.status == ReservationStatus.completed) {
      return BusinessRuleResult.failure(
        'No se puede cancelar una reserva completada',
        ReservationError.alreadyCompleted,
      );
    }

    // No se puede cancelar si ya pasó
    if (reservation.startTime.isBefore(currentTime)) {
      return BusinessRuleResult.failure(
        'No se puede cancelar una reserva que ya comenzó',
        ReservationError.reservationStarted,
      );
    }

    // Política de cancelación: mínimo 2 horas de anticipación
    const minimumCancellationHours = 2;
    final minimumCancellationTime = reservation.startTime.subtract(
      const Duration(hours: minimumCancellationHours),
    );

    if (currentTime.isAfter(minimumCancellationTime)) {
      return BusinessRuleResult.failure(
        'Las reservas deben cancelarse al menos $minimumCancellationHours horas antes del horario programado',
        ReservationError.cancellationTooLate,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Validar horarios básicos (duración, orden, etc.)
  BusinessRuleResult _validateBasicTimeRules(
    DateTime startTime,
    DateTime endTime,
  ) {
    final now = DateTime.now();

    // La reserva no puede ser en el pasado
    if (startTime.isBefore(now)) {
      return BusinessRuleResult.failure(
        'No se pueden hacer reservas en el pasado',
        ReservationError.pastTime,
      );
    }

    // La hora de fin debe ser posterior a la de inicio
    if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
      return BusinessRuleResult.failure(
        'La hora de fin debe ser posterior a la hora de inicio',
        ReservationError.invalidTimeRange,
      );
    }

    // Duración mínima
    final durationMinutes = endTime.difference(startTime).inMinutes;
    final minDurationMinutes = _remoteConfigRepository
        .getReservationDurationMinutes();

    if (durationMinutes < minDurationMinutes) {
      return BusinessRuleResult.failure(
        'La reserva debe tener una duración mínima de $minDurationMinutes minutos',
        ReservationError.durationTooShort,
      );
    }

    // Duración máxima (ejemplo: 3 horas)
    const maxDurationMinutes = 180;
    if (durationMinutes > maxDurationMinutes) {
      return BusinessRuleResult.failure(
        'La reserva no puede exceder $maxDurationMinutes minutos',
        ReservationError.durationTooLong,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Validar horarios de operación
  BusinessRuleResult _validateOperatingHours(DateTime startTime) {
    final hour = startTime.hour;

    // Horarios de operación: 8:00 a 22:00
    if (hour < 8 || hour >= 22) {
      return BusinessRuleResult.failure(
        'Las reservas solo se pueden hacer entre las 08:00 y las 22:00',
        ReservationError.outsideOperatingHours,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Validar disponibilidad del slot
  BusinessRuleResult validateSlotAvailability(
    String courtId,
    DateTime startTime,
    DateTime endTime,
    List<Reservation> existingReservations,
  ) {
    // Filtrar reservas de esta pista que estén confirmadas
    final conflictingReservations = existingReservations
        .where(
          (reservation) =>
              reservation.courtId == courtId &&
              reservation.status == ReservationStatus.confirmed &&
              // Verificar superposición de horarios
              startTime.isBefore(reservation.endTime) &&
              endTime.isAfter(reservation.startTime),
        )
        .toList();

    if (conflictingReservations.isNotEmpty) {
      return BusinessRuleResult.failure(
        'El horario seleccionado está ocupado',
        ReservationError.slotOccupied,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Validar límites por usuario
  BusinessRuleResult _validateUserLimits(
    String userId,
    DateTime reservationDate,
    List<Reservation> existingReservations,
    Map<String, dynamic>? userProfile,
  ) {
    final userReservations = existingReservations
        .where((r) => r.userId == userId)
        .toList();

    // Límite de reservas activas
    final activeReservations = userReservations
        .where((r) => r.status == ReservationStatus.confirmed)
        .length;

    const maxActiveReservations = 3;
    if (activeReservations >= maxActiveReservations) {
      return BusinessRuleResult.failure(
        'Has alcanzado el límite máximo de $maxActiveReservations reservas activas',
        ReservationError.maxActiveReservationsReached,
      );
    }

    // Límite de una reserva por día
    final reservationDay = DateTime(
      reservationDate.year,
      reservationDate.month,
      reservationDate.day,
    );

    final reservationsToday = userReservations.where((r) {
      final rDay = DateTime(
        r.startTime.year,
        r.startTime.month,
        r.startTime.day,
      );
      return rDay == reservationDay && r.status == ReservationStatus.confirmed;
    }).length;

    const maxReservationsPerDay = 1;
    if (reservationsToday >= maxReservationsPerDay) {
      return BusinessRuleResult.failure(
        'Solo se permite una reserva por día',
        ReservationError.maxDailyReservationsReached,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Validar política de reservas con anticipación
  BusinessRuleResult _validateAdvanceBookingPolicy(DateTime startTime) {
    final now = DateTime.now();
    final daysInAdvance = startTime.difference(now).inDays;

    // Obtener máximo de días desde Remote Config
    final maxDaysAdvance = _remoteConfigRepository.getMaxDaysAdvance();

    if (daysInAdvance > maxDaysAdvance) {
      return BusinessRuleResult.failure(
        'No se pueden hacer reservas con más de $maxDaysAdvance días de anticipación',
        ReservationError.tooFarInAdvance,
      );
    }

    return BusinessRuleResult.success();
  }

  /// Obtener restricciones para un usuario específico
  UserRestrictions getUserRestrictions({
    required String userId,
    required List<Reservation> userReservations,
    Map<String, dynamic>? userProfile,
  }) {
    final activeCount = userReservations
        .where((r) => r.status == ReservationStatus.confirmed)
        .length;

    final todayCount = userReservations.where((r) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final rDay = DateTime(
        r.startTime.year,
        r.startTime.month,
        r.startTime.day,
      );
      return rDay == today && r.status == ReservationStatus.confirmed;
    }).length;

    return UserRestrictions(
      maxActiveReservations: 3,
      currentActiveReservations: activeCount,
      maxDailyReservations: 1,
      currentDailyReservations: todayCount,
      canMakeReservation: activeCount < 3 && todayCount < 1,
      nextAvailableReservationDate: todayCount >= 1
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.now(),
    );
  }
}

/// Resultado de una validación de regla de negocio
class BusinessRuleResult {
  final bool isValid;
  final String? errorMessage;
  final ReservationError? errorCode;

  const BusinessRuleResult._({
    required this.isValid,
    this.errorMessage,
    this.errorCode,
  });

  factory BusinessRuleResult.success() =>
      const BusinessRuleResult._(isValid: true);

  factory BusinessRuleResult.failure(String message, ReservationError code) =>
      BusinessRuleResult._(
        isValid: false,
        errorMessage: message,
        errorCode: code,
      );
}

/// Códigos de error para reservas
enum ReservationError {
  // Errores de tiempo
  pastTime,
  invalidTimeRange,
  durationTooShort,
  durationTooLong,
  outsideOperatingHours,

  // Errores de disponibilidad
  slotOccupied,

  // Errores de límites de usuario
  maxActiveReservationsReached,
  maxDailyReservationsReached,
  tooFarInAdvance,

  // Errores de cancelación
  alreadyCancelled,
  alreadyCompleted,
  reservationStarted,
  cancellationTooLate,

  // Errores generales
  userNotFound,
  courtNotFound,
  unknown,
}

/// Restricciones aplicables a un usuario
class UserRestrictions {
  final int maxActiveReservations;
  final int currentActiveReservations;
  final int maxDailyReservations;
  final int currentDailyReservations;
  final bool canMakeReservation;
  final DateTime nextAvailableReservationDate;

  const UserRestrictions({
    required this.maxActiveReservations,
    required this.currentActiveReservations,
    required this.maxDailyReservations,
    required this.currentDailyReservations,
    required this.canMakeReservation,
    required this.nextAvailableReservationDate,
  });

  /// Espacios disponibles para reservas activas
  int get availableActiveSlots =>
      maxActiveReservations - currentActiveReservations;

  /// Reservas diarias disponibles
  int get availableDailySlots =>
      maxDailyReservations - currentDailyReservations;

  /// Mensaje descriptivo del estado de restricciones
  String get restrictionMessage {
    if (canMakeReservation) {
      return 'Puedes hacer reservas normalmente';
    }

    if (currentActiveReservations >= maxActiveReservations) {
      return 'Has alcanzado el límite de $maxActiveReservations reservas activas';
    }

    if (currentDailyReservations >= maxDailyReservations) {
      return 'Ya tienes una reserva para hoy. Próxima disponible: ${_formatDate(nextAvailableReservationDate)}';
    }

    return 'No puedes hacer reservas en este momento';
  }

  String _formatDate(DateTime date) {
    const weekdays = [
      '',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return weekdays[date.weekday];
  }
}
