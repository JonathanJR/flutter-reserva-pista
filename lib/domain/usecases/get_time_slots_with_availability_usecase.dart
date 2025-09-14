import '../models/time_slot.dart';
import '../models/reservation.dart';
import '../models/reservation_status.dart';
import '../repositories/remote_config_repository.dart';

/// Use case para generar slots de tiempo con verificación de disponibilidad
class GetTimeSlotsWithAvailabilityUseCase {
  final RemoteConfigRepository _remoteConfigRepository;

  const GetTimeSlotsWithAvailabilityUseCase(this._remoteConfigRepository);

  /// Generar slots de tiempo para una fecha específica con disponibilidad real
  DayTimeSlots execute(
    DateTime date,
    String courtId, {
    List<Reservation>? existingReservations,
  }) {
    final morningConfig = _remoteConfigRepository.getMorningConfig();
    final afternoonConfig = _remoteConfigRepository.getAfternoonConfig();
    final durationMinutes = _remoteConfigRepository
        .getReservationDurationMinutes();

    // Filtrar reservas de esta pista para esta fecha
    final courtReservationsForDate = (existingReservations ?? [])
        .where(
          (reservation) =>
              reservation.courtId == courtId &&
              reservation.status == ReservationStatus.confirmed &&
              _isSameDay(reservation.startTime, date),
        )
        .toList();

    final morningSlots = _generateSlotsWithAvailability(
      date: date,
      startHour: morningConfig['start_hour']!,
      startMinute: morningConfig['start_minute']!,
      endHour: morningConfig['end_hour']!,
      endMinute: morningConfig['end_minute']!,
      durationMinutes: durationMinutes,
      period: TimeSlotPeriod.morning,
      existingReservations: courtReservationsForDate,
    );

    final afternoonSlots = _generateSlotsWithAvailability(
      date: date,
      startHour: afternoonConfig['start_hour']!,
      startMinute: afternoonConfig['start_minute']!,
      endHour: afternoonConfig['end_hour']!,
      endMinute: afternoonConfig['end_minute']!,
      durationMinutes: durationMinutes,
      period: TimeSlotPeriod.afternoon,
      existingReservations: courtReservationsForDate,
    );

    return DayTimeSlots(
      date: date,
      morningSlots: morningSlots,
      afternoonSlots: afternoonSlots,
    );
  }

  /// Generar lista de slots para un período específico con verificación de disponibilidad
  List<TimeSlot> _generateSlotsWithAvailability({
    required DateTime date,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int durationMinutes,
    required TimeSlotPeriod period,
    required List<Reservation> existingReservations,
  }) {
    final slots = <TimeSlot>[];

    // Crear DateTime para el inicio y fin del período
    final periodStart = DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );
    final periodEnd = DateTime(
      date.year,
      date.month,
      date.day,
      endHour,
      endMinute,
    );

    // Generar slots consecutivos
    var currentSlotStart = periodStart;

    while (currentSlotStart
            .add(Duration(minutes: durationMinutes))
            .isBefore(periodEnd) ||
        currentSlotStart
            .add(Duration(minutes: durationMinutes))
            .isAtSameMomentAs(periodEnd)) {
      final slotEnd = currentSlotStart.add(Duration(minutes: durationMinutes));

      // Verificar disponibilidad contra reservas existentes
      final isAvailable = _isSlotAvailable(
        slotStart: currentSlotStart,
        slotEnd: slotEnd,
        existingReservations: existingReservations,
      );

      slots.add(
        TimeSlot(
          startTime: currentSlotStart,
          endTime: slotEnd,
          isAvailable: isAvailable,
          period: period,
        ),
      );

      // Preparar para el siguiente slot
      currentSlotStart = slotEnd;
    }

    return slots;
  }

  /// Verificar si un slot específico está disponible
  bool _isSlotAvailable({
    required DateTime slotStart,
    required DateTime slotEnd,
    required List<Reservation> existingReservations,
  }) {
    // Verificar si alguna reserva existente se superpone con este slot
    return !existingReservations.any((reservation) {
      // Hay superposición si:
      // - El slot comienza antes de que termine la reserva Y
      // - El slot termina después de que comience la reserva
      return slotStart.isBefore(reservation.endTime) &&
          slotEnd.isAfter(reservation.startTime);
    });
  }

  /// Verificar si dos fechas son del mismo día
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Verificar disponibilidad de un slot específico (método de conveniencia)
  bool isSpecificSlotAvailable({
    required DateTime slotStart,
    required String courtId,
    required List<Reservation> existingReservations,
  }) {
    final durationMinutes = _remoteConfigRepository
        .getReservationDurationMinutes();
    final slotEnd = slotStart.add(Duration(minutes: durationMinutes));

    // Filtrar reservas de esta pista para esta fecha
    final courtReservationsForDate = existingReservations
        .where(
          (reservation) =>
              reservation.courtId == courtId &&
              reservation.status == ReservationStatus.confirmed &&
              _isSameDay(reservation.startTime, slotStart),
        )
        .toList();

    return _isSlotAvailable(
      slotStart: slotStart,
      slotEnd: slotEnd,
      existingReservations: courtReservationsForDate,
    );
  }
}
