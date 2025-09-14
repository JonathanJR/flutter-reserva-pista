import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_dto.dart';
import '../../domain/models/reservation_status.dart';

/// DataSource remoto para reservas desde Firestore
class ReservationRemoteDataSource {
  final FirebaseFirestore _firestore;

  const ReservationRemoteDataSource(this._firestore);

  /// Colección de reservas en Firestore
  static const String _reservationsCollection = 'reservations';

  /// Obtener todas las reservas activas (confirmed) en un rango de fechas
  /// Útil para mostrar disponibilidad en el calendario
  Stream<List<ReservationDto>> getActiveReservationsStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    var query = _firestore
        .collection(_reservationsCollection)
        .where('status', isEqualTo: ReservationStatus.confirmed.firestoreValue);

    // Filtrar por rango de fechas si se especifica
    if (startDate != null) {
      query = query.where(
        'startTime',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }
    if (endDate != null) {
      query = query.where(
        'startTime',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReservationDto.fromQuerySnapshot(doc))
              .toList(),
        );
  }

  /// Obtener reservas de un usuario específico
  Stream<List<ReservationDto>> getUserReservationsStream(String userId) {
    return _firestore
        .collection(_reservationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReservationDto.fromQuerySnapshot(doc))
              .toList(),
        );
  }

  /// Obtener reservas de una pista específica
  Stream<List<ReservationDto>> getCourtReservationsStream(String courtId) {
    return _firestore
        .collection(_reservationsCollection)
        .where('courtId', isEqualTo: courtId)
        .where('status', isEqualTo: ReservationStatus.confirmed.firestoreValue)
        .orderBy('startTime')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReservationDto.fromQuerySnapshot(doc))
              .toList(),
        );
  }

  /// Crear una nueva reserva
  Future<String> createReservation(ReservationDto reservationDto) async {
    try {
      // Validar que no haya conflicto de horario
      await _validateReservationSlot(reservationDto);

      final docRef = await _firestore
          .collection(_reservationsCollection)
          .add(reservationDto.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear la reserva: ${e.toString()}');
    }
  }

  /// Cancelar una reserva (cambiar estado a cancelled)
  Future<void> cancelReservation(String reservationId, String reason) async {
    try {
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .update({
            'status': ReservationStatus.cancelled.firestoreValue,
            'cancellationReason': reason,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error al cancelar la reserva: ${e.toString()}');
    }
  }

  /// Marcar reserva como completada
  Future<void> completeReservation(String reservationId) async {
    try {
      await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .update({
            'status': ReservationStatus.completed.firestoreValue,
            'updatedAt': Timestamp.now(),
          });
    } catch (e) {
      throw Exception('Error al completar la reserva: ${e.toString()}');
    }
  }

  /// Obtener una reserva específica por ID
  Future<ReservationDto?> getReservationById(String reservationId) async {
    try {
      final doc = await _firestore
          .collection(_reservationsCollection)
          .doc(reservationId)
          .get();

      if (!doc.exists) return null;

      return ReservationDto.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error al obtener la reserva: ${e.toString()}');
    }
  }

  /// Validar que no haya conflicto en el slot de tiempo
  Future<void> _validateReservationSlot(ReservationDto reservation) async {
    final conflictingReservations = await _firestore
        .collection(_reservationsCollection)
        .where('courtId', isEqualTo: reservation.courtId)
        .where('status', isEqualTo: ReservationStatus.confirmed.firestoreValue)
        .where('startTime', isLessThan: reservation.endTime)
        .where('endTime', isGreaterThan: reservation.startTime)
        .get();

    if (conflictingReservations.docs.isNotEmpty) {
      throw Exception('Ya existe una reserva para ese horario');
    }
  }

  /// Obtener estadísticas de reservas de un usuario
  Future<Map<String, int>> getUserReservationStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_reservationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      int confirmed = 0;
      int cancelled = 0;
      int completed = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;

        switch (status) {
          case 'confirmed':
            confirmed++;
            break;
          case 'cancelled':
            cancelled++;
            break;
          case 'completed':
            completed++;
            break;
        }
      }

      return {
        'confirmed': confirmed,
        'cancelled': cancelled,
        'completed': completed,
        'total': confirmed + cancelled + completed,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }

  /// Limpiar reservas antiguas (para uso con Cloud Functions)
  /// Borra reservas completed o cancelled más antiguas que X días
  Future<int> cleanupOldReservations({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final batch = _firestore.batch();
      int deletedCount = 0;

      // Obtener reservas antiguas completed o cancelled
      final oldReservations = await _firestore
          .collection(_reservationsCollection)
          .where('updatedAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .where(
            'status',
            whereIn: [
              ReservationStatus.completed.firestoreValue,
              ReservationStatus.cancelled.firestoreValue,
            ],
          )
          .get();

      for (final doc in oldReservations.docs) {
        batch.delete(doc.reference);
        deletedCount++;
      }

      if (deletedCount > 0) {
        await batch.commit();
      }

      return deletedCount;
    } catch (e) {
      throw Exception('Error al limpiar reservas antiguas: ${e.toString()}');
    }
  }
}
