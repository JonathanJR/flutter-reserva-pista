/// Estados posibles de una reserva
enum ReservationStatus {
  /// Reserva confirmada y activa (pendiente de usar)
  confirmed,

  /// Reserva cancelada por el usuario o administrador
  cancelled,

  /// Reserva ya completada/consumida
  completed;

  /// Obtener string para Firestore
  String get firestoreValue {
    switch (this) {
      case ReservationStatus.confirmed:
        return 'confirmed';
      case ReservationStatus.cancelled:
        return 'cancelled';
      case ReservationStatus.completed:
        return 'completed';
    }
  }

  /// Crear desde string de Firestore
  static ReservationStatus fromFirestoreValue(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      default:
        throw ArgumentError('Invalid reservation status: $value');
    }
  }

  /// Verificar si la reserva está activa (visible en calendario)
  bool get isActive => this == ReservationStatus.confirmed;

  /// Verificar si la reserva cuenta para el total del usuario
  bool get countsForUser =>
      this == ReservationStatus.confirmed ||
      this == ReservationStatus.completed;

  /// Texto para mostrar al usuario
  String get displayText {
    switch (this) {
      case ReservationStatus.confirmed:
        return 'Confirmada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.completed:
        return 'Completada';
    }
  }

  /// Color asociado al estado
  String get colorHex {
    switch (this) {
      case ReservationStatus.confirmed:
        return '#4CAF50'; // Verde
      case ReservationStatus.cancelled:
        return '#F44336'; // Rojo
      case ReservationStatus.completed:
        return '#2196F3'; // Azul
    }
  }
}
