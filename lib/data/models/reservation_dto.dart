import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/reservation.dart';
import '../../domain/models/reservation_status.dart';

/// Data Transfer Object para Reservation desde/hacia Firestore
class ReservationDto {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final Timestamp startTime;
  final Timestamp endTime;
  final String status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? cancellationReason;

  const ReservationDto({
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

  /// Crear ReservationDto desde DocumentSnapshot de Firestore
  factory ReservationDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReservationDto(
      id: doc.id,
      userId: data['userId'] as String,
      courtId: data['courtId'] as String,
      courtName: data['courtName'] as String,
      startTime: data['startTime'] as Timestamp,
      endTime: data['endTime'] as Timestamp,
      status: data['status'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  /// Crear ReservationDto desde QueryDocumentSnapshot de Firestore
  factory ReservationDto.fromQuerySnapshot(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReservationDto(
      id: doc.id,
      userId: data['userId'] as String,
      courtId: data['courtId'] as String,
      courtName: data['courtName'] as String,
      startTime: data['startTime'] as Timestamp,
      endTime: data['endTime'] as Timestamp,
      status: data['status'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  /// Crear ReservationDto desde Map (útil para testing)
  factory ReservationDto.fromMap(String id, Map<String, dynamic> data) {
    return ReservationDto(
      id: id,
      userId: data['userId'] as String,
      courtId: data['courtId'] as String,
      courtName: data['courtName'] as String,
      startTime: data['startTime'] as Timestamp,
      endTime: data['endTime'] as Timestamp,
      status: data['status'] as String,
      createdAt: data['createdAt'] as Timestamp,
      updatedAt: data['updatedAt'] as Timestamp,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  /// Convertir a Map para Firestore (sin el ID)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'courtId': courtId,
      'courtName': courtName,
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (cancellationReason != null) 'cancellationReason': cancellationReason,
    };
  }

  /// Convertir DTO a modelo de dominio
  Reservation toDomain() {
    return Reservation(
      id: id,
      userId: userId,
      courtId: courtId,
      courtName: courtName,
      startTime: startTime.toDate(),
      endTime: endTime.toDate(),
      status: ReservationStatus.fromFirestoreValue(status),
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt.toDate(),
      cancellationReason: cancellationReason,
    );
  }

  /// Crear DTO desde modelo de dominio
  factory ReservationDto.fromDomain(Reservation reservation) {
    return ReservationDto(
      id: reservation.id,
      userId: reservation.userId,
      courtId: reservation.courtId,
      courtName: reservation.courtName,
      startTime: Timestamp.fromDate(reservation.startTime),
      endTime: Timestamp.fromDate(reservation.endTime),
      status: reservation.status.firestoreValue,
      createdAt: Timestamp.fromDate(reservation.createdAt),
      updatedAt: Timestamp.fromDate(reservation.updatedAt),
      cancellationReason: reservation.cancellationReason,
    );
  }

  /// Crear DTO para nueva reserva (sin ID, con timestamps actuales)
  factory ReservationDto.forCreation({
    required String userId,
    required String courtId,
    required String courtName,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final now = Timestamp.now();

    return ReservationDto(
      id: '', // Se asignará al crear en Firestore
      userId: userId,
      courtId: courtId,
      courtName: courtName,
      startTime: Timestamp.fromDate(startTime),
      endTime: Timestamp.fromDate(endTime),
      status: ReservationStatus.confirmed.firestoreValue,
      createdAt: now,
      updatedAt: now,
      cancellationReason: null,
    );
  }

  /// Crear copia con nuevos valores
  ReservationDto copyWith({
    String? id,
    String? userId,
    String? courtId,
    String? courtName,
    Timestamp? startTime,
    Timestamp? endTime,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? cancellationReason,
  }) {
    return ReservationDto(
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
}
