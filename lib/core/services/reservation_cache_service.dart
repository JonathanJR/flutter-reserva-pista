import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/reservation.dart';

/// Servicio para manejar el cache global de reservas con invalidación manual
class ReservationCacheService {
  // Controladores para invalidación manual
  StreamController<void>? _refreshController;

  ReservationCacheService();

  /// Stream controller para forzar refresh del cache
  StreamController<void> get _controller {
    _refreshController ??= StreamController<void>.broadcast();
    return _refreshController!;
  }

  /// Stream que emite cuando se debe refrescar el cache
  Stream<void> get refreshStream => _controller.stream;

  /// Invalidar cache manualmente (ej: después de crear/cancelar reserva)
  void invalidateCache({String? reason}) {
    if (_refreshController?.hasListener == true) {
      _controller.add(null);
      logCacheAction('Cache invalidado manualmente', reason: reason);
    }
  }

  /// Invalidar cache después de crear una reserva
  void invalidateAfterCreate(String reservationId) {
    invalidateCache(reason: 'Reserva creada: $reservationId');
  }

  /// Invalidar cache después de cancelar una reserva
  void invalidateAfterCancel(String reservationId) {
    invalidateCache(reason: 'Reserva cancelada: $reservationId');
  }

  /// Invalidar cache después de completar una reserva
  void invalidateAfterComplete(String reservationId) {
    invalidateCache(reason: 'Reserva completada: $reservationId');
  }

  /// Obtener estadísticas del cache desde las reservas en memoria
  CacheStats getCacheStats(List<Reservation> reservations) {
    if (reservations.isEmpty) {
      return CacheStats.empty();
    }

    final now = DateTime.now();
    int confirmed = 0;
    int cancelled = 0;
    int completed = 0;
    int todayCount = 0;
    int futureCount = 0;

    DateTime? oldestReservation;
    DateTime? newestReservation;

    for (final reservation in reservations) {
      // Contar por estado
      switch (reservation.status.firestoreValue) {
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

      // Contar por tiempo
      if (reservation.isToday) todayCount++;
      if (reservation.isFuture) futureCount++;

      // Tracking de fechas
      if (oldestReservation == null ||
          reservation.startTime.isBefore(oldestReservation)) {
        oldestReservation = reservation.startTime;
      }
      if (newestReservation == null ||
          reservation.startTime.isAfter(newestReservation)) {
        newestReservation = reservation.startTime;
      }
    }

    return CacheStats(
      totalReservations: reservations.length,
      confirmedCount: confirmed,
      cancelledCount: cancelled,
      completedCount: completed,
      todayCount: todayCount,
      futureCount: futureCount,
      oldestReservation: oldestReservation,
      newestReservation: newestReservation,
      lastUpdated: now,
    );
  }

  /// Obtener reservas de un usuario específico desde el cache
  List<Reservation> getUserReservationsFromCache(
    List<Reservation> allReservations,
    String userId,
  ) {
    return allReservations
        .where((reservation) => reservation.userId == userId)
        .toList();
  }

  /// Obtener disponibilidad de pista desde el cache
  Map<String, bool> getCourtAvailabilityFromCache(
    List<Reservation> allReservations,
    String courtId,
    List<DateTime> timeSlots,
  ) {
    final Map<String, bool> availability = {};

    // Filtrar reservas de esta pista específica que estén confirmadas
    final courtReservations = allReservations
        .where(
          (reservation) =>
              reservation.courtId == courtId && reservation.status.isActive,
        )
        .toList();

    // Verificar cada slot
    for (final slot in timeSlots) {
      final slotKey = _generateSlotKey(courtId, slot);
      final isOccupied = courtReservations.any(
        (reservation) => reservation.startTime.isAtSameMomentAs(slot),
      );

      availability[slotKey] = !isOccupied;
    }

    return availability;
  }

  /// Generar clave única para un slot de tiempo
  String _generateSlotKey(String courtId, DateTime slot) {
    return '${courtId}_${slot.millisecondsSinceEpoch}';
  }

  /// Log de acciones del cache (solo en debug)
  void logCacheAction(String action, {String? reason}) {
    final timestamp = DateTime.now().toIso8601String();
    final message = reason != null ? '$action - Razón: $reason' : action;

    // Solo log en debug
    if (kDebugMode) {
      debugPrint('🔄 [$timestamp] ReservationCache: $message');
    }
  }

  /// Limpiar recursos
  void dispose() {
    _refreshController?.close();
    _refreshController = null;
  }
}

/// Estadísticas del cache de reservas
class CacheStats {
  final int totalReservations;
  final int confirmedCount;
  final int cancelledCount;
  final int completedCount;
  final int todayCount;
  final int futureCount;
  final DateTime? oldestReservation;
  final DateTime? newestReservation;
  final DateTime lastUpdated;

  const CacheStats({
    required this.totalReservations,
    required this.confirmedCount,
    required this.cancelledCount,
    required this.completedCount,
    required this.todayCount,
    required this.futureCount,
    this.oldestReservation,
    this.newestReservation,
    required this.lastUpdated,
  });

  factory CacheStats.empty() {
    return CacheStats(
      totalReservations: 0,
      confirmedCount: 0,
      cancelledCount: 0,
      completedCount: 0,
      todayCount: 0,
      futureCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Total de reservas activas (confirmed)
  int get activeCount => confirmedCount;

  /// Porcentaje de reservas canceladas
  double get cancellationRate {
    if (totalReservations == 0) return 0.0;
    return (cancelledCount / totalReservations) * 100;
  }

  /// Rango de fechas del cache
  String get dateRange {
    if (oldestReservation == null || newestReservation == null) {
      return 'Sin reservas';
    }

    final oldest = oldestReservation!;
    final newest = newestReservation!;

    if (oldest.day == newest.day &&
        oldest.month == newest.month &&
        oldest.year == newest.year) {
      return '${oldest.day}/${oldest.month}/${oldest.year}';
    }

    return '${oldest.day}/${oldest.month}/${oldest.year} - ${newest.day}/${newest.month}/${newest.year}';
  }

  @override
  String toString() {
    return 'CacheStats(total: $totalReservations, activas: $activeCount, hoy: $todayCount, futuras: $futureCount)';
  }
}
