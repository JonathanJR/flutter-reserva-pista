import 'package:equatable/equatable.dart';
import 'reservation_status.dart';

/// Modelo de dominio para una Reserva
class Reservation extends Equatable {
  final String id;
  final String userId;
  final String courtId;
  final String courtName; // Para evitar lookups adicionales
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason; // Si fue cancelada

  const Reservation({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
  });

  /// Duración de la reserva en minutos
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  /// Verificar si la reserva es para hoy
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reservationDate = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
    );
    return today == reservationDate;
  }

  /// Verificar si la reserva es futura
  bool get isFuture {
    return startTime.isAfter(DateTime.now());
  }

  /// Verificar si la reserva ya pasó
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Verificar si la reserva está en curso
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime) && status.isActive;
  }

  /// Clave única para el slot de tiempo (útil para disponibilidad)
  String get slotKey {
    return '${courtId}_${_formatDateTime(startTime)}_${_formatDateTime(endTime)}';
  }

  /// Formatear fecha y hora para mostrar al usuario
  String get displayDateTime {
    return '${_formatDate(startTime)} • ${_formatTime(startTime)}-${_formatTime(endTime)}';
  }

  /// Formatear solo la hora para mostrar
  String get displayTime {
    return '${_formatTime(startTime)}-${_formatTime(endTime)}';
  }

  /// Verificar si se puede cancelar (ejemplo: hasta 2 horas antes)
  bool get canBeCancelled {
    if (status != ReservationStatus.confirmed) return false;
    final now = DateTime.now();
    final hoursUntilStart = startTime.difference(now).inHours;
    return hoursUntilStart >= 2; // Mínimo 2 horas de anticipación
  }

  /// Tiempo restante hasta que inicie la reserva (en texto)
  String get timeUntilStart {
    if (!isFuture) return '';

    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} día(s)';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora(s)';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto(s)';
    } else {
      return 'Ya comenzó';
    }
  }

  /// Crear copia con nuevos valores
  Reservation copyWith({
    String? id,
    String? userId,
    String? courtId,
    String? courtName,
    DateTime? startTime,
    DateTime? endTime,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courtId: courtId ?? this.courtId,
      courtName: courtName ?? this.courtName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    courtId,
    courtName,
    startTime,
    endTime,
    status,
    createdAt,
    updatedAt,
    cancellationReason,
  ];

  // Métodos privados para formateo
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}${dateTime.month.toString().padLeft(2, '0')}${dateTime.day.toString().padLeft(2, '0')}_${dateTime.hour.toString().padLeft(2, '0')}${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
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
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    final weekday = weekdays[dateTime.weekday];
    final day = dateTime.day;
    final month = months[dateTime.month];

    return '$weekday, $day de $month';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
