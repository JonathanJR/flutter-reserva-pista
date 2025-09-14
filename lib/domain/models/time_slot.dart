import 'package:equatable/equatable.dart';

/// Modelo de dominio para un slot de tiempo de reserva
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final TimeSlotPeriod period;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.period,
  });

  /// Formatear horario para mostrar (ej: "10:00 - 11:30")
  String get displayTime {
    final start = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  /// Duración del slot en minutos
  int get durationMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  TimeSlot copyWith({
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
    TimeSlotPeriod? period,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      period: period ?? this.period,
    );
  }

  @override
  List<Object> get props => [startTime, endTime, isAvailable, period];
}

/// Períodos del día para clasificar los slots
enum TimeSlotPeriod {
  morning('Mañana'),
  afternoon('Tarde');

  const TimeSlotPeriod(this.displayName);
  
  final String displayName;
}

/// Contenedor para los slots agrupados por período
class DayTimeSlots extends Equatable {
  final DateTime date;
  final List<TimeSlot> morningSlots;
  final List<TimeSlot> afternoonSlots;

  const DayTimeSlots({
    required this.date,
    required this.morningSlots,
    required this.afternoonSlots,
  });

  /// Obtener todos los slots del día
  List<TimeSlot> get allSlots => [...morningSlots, ...afternoonSlots];

  /// Verificar si hay al menos un slot disponible
  bool get hasAvailableSlots {
    return allSlots.any((slot) => slot.isAvailable);
  }

  /// Obtener número total de slots disponibles
  int get availableSlotsCount {
    return allSlots.where((slot) => slot.isAvailable).length;
  }

  @override
  List<Object> get props => [date, morningSlots, afternoonSlots];
}
