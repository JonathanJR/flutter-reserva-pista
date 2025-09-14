import '../models/time_slot.dart';
import '../repositories/remote_config_repository.dart';

/// Use case para generar slots de tiempo disponibles para reservas
class GetTimeSlotsUseCase {
  final RemoteConfigRepository _remoteConfigRepository;

  const GetTimeSlotsUseCase(this._remoteConfigRepository);

  /// Generar slots de tiempo para una fecha específica
  DayTimeSlots execute(DateTime date) {
    final morningConfig = _remoteConfigRepository.getMorningConfig();
    final afternoonConfig = _remoteConfigRepository.getAfternoonConfig();
    final durationMinutes = _remoteConfigRepository.getReservationDurationMinutes();

    final morningSlots = _generateSlots(
      date: date,
      startHour: morningConfig['start_hour']!,
      startMinute: morningConfig['start_minute']!,
      endHour: morningConfig['end_hour']!,
      endMinute: morningConfig['end_minute']!,
      durationMinutes: durationMinutes,
      period: TimeSlotPeriod.morning,
    );

    final afternoonSlots = _generateSlots(
      date: date,
      startHour: afternoonConfig['start_hour']!,
      startMinute: afternoonConfig['start_minute']!,
      endHour: afternoonConfig['end_hour']!,
      endMinute: afternoonConfig['end_minute']!,
      durationMinutes: durationMinutes,
      period: TimeSlotPeriod.afternoon,
    );

    return DayTimeSlots(
      date: date,
      morningSlots: morningSlots,
      afternoonSlots: afternoonSlots,
    );
  }

  /// Generar lista de slots para un período específico
  List<TimeSlot> _generateSlots({
    required DateTime date,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int durationMinutes,
    required TimeSlotPeriod period,
  }) {
    final slots = <TimeSlot>[];

    // Crear DateTime para el inicio y fin del período
    final periodStart = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final periodEnd = DateTime(date.year, date.month, date.day, endHour, endMinute);

    // Generar slots consecutivos
    var currentSlotStart = periodStart;
    
    while (currentSlotStart.add(Duration(minutes: durationMinutes)).isBefore(periodEnd) || 
           currentSlotStart.add(Duration(minutes: durationMinutes)).isAtSameMomentAs(periodEnd)) {
      
      final slotEnd = currentSlotStart.add(Duration(minutes: durationMinutes));
      
      slots.add(TimeSlot(
        startTime: currentSlotStart,
        endTime: slotEnd,
        isAvailable: true, // Por ahora todos están disponibles
        period: period,
      ));
      
      // Preparar para el siguiente slot
      currentSlotStart = slotEnd;
    }

    return slots;
  }
}
