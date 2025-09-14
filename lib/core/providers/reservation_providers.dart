import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../domain/models/reservation.dart';
import '../../domain/models/reservation_status.dart';
import '../../domain/models/time_slot.dart';
import '../../domain/services/reservation_business_rules.dart';
import '../services/reservation_cache_service.dart';
import 'firebase_providers.dart';

// ========================================
// CACHE GLOBAL DE RESERVAS
// ========================================

/// Provider para el servicio de cache de reservas
final reservationCacheServiceProvider =
    Provider.autoDispose<ReservationCacheService>((ref) {
      final service = ReservationCacheService();

      // Limpiar recursos cuando el provider se dispose
      ref.onDispose(() {
        service.dispose();
      });

      return service;
    });

/// Provider principal para el cache global de reservas activas
/// Este es el ÚNICO provider que hace queries a Firestore
final reservationsGlobalCacheProvider =
    StreamProvider.autoDispose<List<Reservation>>((ref) {
      final repository = ref.read(reservationRepositoryProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      // Rango de fechas para el cache (últimos 7 días + próximos 14 días)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 7));
      final endDate = now.add(const Duration(days: 14));

      // Stream controller para combinar el stream original con invalidaciones
      late StreamController<List<Reservation>> controller;
      StreamSubscription<List<Reservation>>? reservationsSubscription;
      StreamSubscription<void>? invalidationSubscription;

      controller = StreamController<List<Reservation>>.broadcast(
        onListen: () {
          // Suscribirse al stream original de reservas
          reservationsSubscription = repository
              .getActiveReservationsStream(
                startDate: startDate,
                endDate: endDate,
              )
              .listen(
                (reservations) {
                  controller.add(reservations);
                  cacheService.logCacheAction(
                    'Cache actualizado: ${reservations.length} reservas cargadas',
                  );
                },
                onError: (error) {
                  controller.addError(error);
                  cacheService.logCacheAction('Error en cache: $error');
                },
              );

          // Suscribirse a invalidaciones manuales
          invalidationSubscription = cacheService.refreshStream.listen((_) {
            // Cuando se invalida manualmente, re-suscribirse al stream
            reservationsSubscription?.cancel();
            reservationsSubscription = repository
                .getActiveReservationsStream(
                  startDate: startDate,
                  endDate: endDate,
                )
                .listen((reservations) {
                  controller.add(reservations);
                  cacheService.logCacheAction(
                    'Cache refrescado manualmente: ${reservations.length} reservas',
                  );
                }, onError: (error) => controller.addError(error));
          });
        },
        onCancel: () {
          reservationsSubscription?.cancel();
          invalidationSubscription?.cancel();
        },
      );

      // Limpiar recursos cuando el provider se dispose
      ref.onDispose(() {
        reservationsSubscription?.cancel();
        invalidationSubscription?.cancel();
        controller.close();
      });

      return controller.stream;
    });

/// Provider para estadísticas del cache
final cacheStatsProvider = Provider.autoDispose<CacheStats>((ref) {
  final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);
  final cacheService = ref.read(reservationCacheServiceProvider);

  return reservationsAsync.when(
    data: (reservations) => cacheService.getCacheStats(reservations),
    loading: () => CacheStats.empty(),
    error: (_, __) => CacheStats.empty(),
  );
});

// ========================================
// PROVIDERS DERIVADOS DEL CACHE GLOBAL
// ========================================

/// Provider para obtener el conteo de reservas de un usuario específico
/// Este provider NO hace queries a Firestore, usa el cache global
final userReservationsCountProvider = Provider.autoDispose.family<int, String>((
  ref,
  userId,
) {
  final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);
  final cacheService = ref.read(reservationCacheServiceProvider);

  return reservationsAsync.when(
    data: (allReservations) {
      final userReservations = cacheService.getUserReservationsFromCache(
        allReservations,
        userId,
      );

      // Solo contar reservas confirmadas para el contador del perfil
      return userReservations
          .where(
            (reservation) => reservation.status == ReservationStatus.confirmed,
          )
          .length;
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});

/// Provider para obtener todas las reservas de un usuario
/// Útil para mostrar el historial completo
final userReservationsProvider = Provider.autoDispose
    .family<List<Reservation>, String>((ref, userId) {
      final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return reservationsAsync.when(
        data: (allReservations) {
          final userReservations = cacheService.getUserReservationsFromCache(
            allReservations,
            userId,
          );

          // Ordenar por fecha de inicio (más recientes primero)
          userReservations.sort((a, b) => b.startTime.compareTo(a.startTime));

          return userReservations;
        },
        loading: () => [],
        error: (_, __) => [],
      );
    });

/// Provider para verificar disponibilidad de slots en una pista específica
/// Este provider NO hace queries a Firestore, usa el cache global
final courtAvailabilityProvider = Provider.autoDispose
    .family<Map<String, bool>, CourtAvailabilityQuery>((ref, query) {
      final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return reservationsAsync.when(
        data: (allReservations) {
          return cacheService.getCourtAvailabilityFromCache(
            allReservations,
            query.courtId,
            query.timeSlots,
          );
        },
        loading: () => {},
        error: (_, __) => {},
      );
    });

/// Provider para verificar si un slot específico está disponible
final isSlotAvailableProvider = Provider.autoDispose
    .family<bool, SlotAvailabilityQuery>((ref, query) {
      final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);

      return reservationsAsync.when(
        data: (allReservations) {
          // Verificar si hay alguna reserva confirmada que ocupe este slot
          return !allReservations.any(
            (reservation) =>
                reservation.courtId == query.courtId &&
                reservation.status == ReservationStatus.confirmed &&
                reservation.startTime.isAtSameMomentAs(query.startTime),
          );
        },
        loading: () => true, // Asumir disponible mientras carga
        error: (_, __) => true, // Asumir disponible en caso de error
      );
    });

/// Provider para obtener reservas de hoy
final todayReservationsProvider = Provider.autoDispose<List<Reservation>>((
  ref,
) {
  final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);

  return reservationsAsync.when(
    data: (allReservations) {
      return allReservations
          .where(
            (reservation) =>
                reservation.isToday &&
                reservation.status == ReservationStatus.confirmed,
          )
          .toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider para obtener reservas futuras
final upcomingReservationsProvider = Provider.autoDispose<List<Reservation>>((
  ref,
) {
  final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);

  return reservationsAsync.when(
    data: (allReservations) {
      final upcoming = allReservations
          .where(
            (reservation) =>
                reservation.isFuture &&
                reservation.status == ReservationStatus.confirmed,
          )
          .toList();

      // Ordenar por fecha de inicio (más próximas primero)
      upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

      return upcoming;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// ========================================
// CLASSES AUXILIARES
// ========================================

/// Query para disponibilidad de pista
class CourtAvailabilityQuery {
  final String courtId;
  final List<DateTime> timeSlots;

  const CourtAvailabilityQuery({
    required this.courtId,
    required this.timeSlots,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourtAvailabilityQuery &&
          runtimeType == other.runtimeType &&
          courtId == other.courtId &&
          _listEquals(timeSlots, other.timeSlots);

  @override
  int get hashCode => Object.hash(
    courtId,
    Object.hashAll(timeSlots.map((slot) => slot.millisecondsSinceEpoch)),
  );

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Query para disponibilidad de slot específico
class SlotAvailabilityQuery {
  final String courtId;
  final DateTime startTime;

  const SlotAvailabilityQuery({required this.courtId, required this.startTime});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SlotAvailabilityQuery &&
          runtimeType == other.runtimeType &&
          courtId == other.courtId &&
          startTime == other.startTime;

  @override
  int get hashCode => Object.hash(courtId, startTime);
}

// ========================================
// PROVIDERS CON AUTO-INVALIDACIÓN
// ========================================

/// Provider para crear reserva con auto-invalidación de cache
final createReservationWithCacheProvider =
    Provider.autoDispose<
      Future<String> Function({
        required String userId,
        required String courtId,
        required String courtName,
        required DateTime startTime,
        required DateTime endTime,
      })
    >((ref) {
      final createUseCase = ref.read(createReservationUseCaseProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return ({
        required String userId,
        required String courtId,
        required String courtName,
        required DateTime startTime,
        required DateTime endTime,
      }) async {
        try {
          final reservationId = await createUseCase.execute(
            userId: userId,
            courtId: courtId,
            courtName: courtName,
            startTime: startTime,
            endTime: endTime,
          );

          // Invalidar cache después de crear exitosamente
          cacheService.invalidateAfterCreate(reservationId);

          return reservationId;
        } catch (e) {
          // En caso de error, también invalidar cache por si quedó en estado inconsistente
          cacheService.invalidateCache(reason: 'Error al crear reserva: $e');
          rethrow;
        }
      };
    });

/// Provider para cancelar reserva con auto-invalidación de cache
final cancelReservationWithCacheProvider =
    Provider.autoDispose<
      Future<void> Function({
        required String reservationId,
        required String userId,
        required String reason,
      })
    >((ref) {
      final cancelUseCase = ref.read(cancelReservationUseCaseProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return ({
        required String reservationId,
        required String userId,
        required String reason,
      }) async {
        try {
          await cancelUseCase.execute(
            reservationId: reservationId,
            userId: userId,
            reason: reason,
          );

          // Invalidar cache después de cancelar exitosamente
          cacheService.invalidateAfterCancel(reservationId);
        } catch (e) {
          // En caso de error, también invalidar cache por si quedó en estado inconsistente
          cacheService.invalidateCache(reason: 'Error al cancelar reserva: $e');
          rethrow;
        }
      };
    });

/// Provider para refresh manual del cache
final refreshCacheProvider = Provider.autoDispose<void Function([String?])>((
  ref,
) {
  final cacheService = ref.read(reservationCacheServiceProvider);

  return ([String? reason]) {
    cacheService.invalidateCache(
      reason: reason ?? 'Refresh manual por usuario',
    );
  };
});

/// Provider para obtener función de refresh con loading state
final refreshCacheWithLoadingProvider =
    StateNotifierProvider.autoDispose<RefreshNotifier, bool>((ref) {
      final cacheService = ref.read(reservationCacheServiceProvider);
      return RefreshNotifier(cacheService);
    });

/// Notifier para manejar el estado de loading del refresh
class RefreshNotifier extends StateNotifier<bool> {
  final ReservationCacheService _cacheService;

  RefreshNotifier(this._cacheService) : super(false);

  /// Refresh con indicador de loading
  Future<void> refresh([String? reason]) async {
    if (state) return; // Ya está refreshing

    state = true;

    try {
      _cacheService.invalidateCache(
        reason: reason ?? 'Refresh manual con loading',
      );

      // Esperar un poco para dar tiempo a que se actualice el stream
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        state = false;
      }
    }
  }
}

// ========================================
// PROVIDERS ESPECÍFICOS PARA VISTAS
// ========================================

/// Provider para obtener time slots con disponibilidad real para CalendarView
final dayTimeSlotsWithAvailabilityProvider = Provider.autoDispose
    .family<DayTimeSlots?, DayTimeSlotsQuery>((ref, query) {
      final timeSlotsUseCase = ref.read(
        getTimeSlotsWithAvailabilityUseCaseProvider,
      );
      final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);

      return reservationsAsync.when(
        data: (allReservations) {
          return timeSlotsUseCase.execute(
            query.date,
            query.courtId,
            existingReservations: allReservations,
          );
        },
        loading: () => null,
        error: (_, __) => null,
      );
    });

/// Query para obtener time slots con disponibilidad
class DayTimeSlotsQuery {
  final DateTime date;
  final String courtId;

  const DayTimeSlotsQuery({required this.date, required this.courtId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayTimeSlotsQuery &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          courtId == other.courtId;

  @override
  int get hashCode => Object.hash(date, courtId);
}

// ========================================
// PROVIDERS AVANZADOS DE GESTIÓN
// ========================================

/// Provider para obtener restricciones del usuario
final userRestrictionsProvider = FutureProvider.autoDispose
    .family<UserRestrictions, String>((ref, userId) async {
      final createUseCase = ref.read(createReservationUseCaseProvider);
      return await createUseCase.getUserRestrictions(userId);
    });

/// Provider mejorado para cancelar reserva con auto-invalidación de cache
final cancelReservationWithCacheAdvancedProvider =
    Provider.autoDispose<
      Future<void> Function({
        required String reservationId,
        required String userId,
        String? reason,
      })
    >((ref) {
      final cancelUseCase = ref.read(cancelReservationUseCaseProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return ({
        required String reservationId,
        required String userId,
        String? reason,
      }) async {
        try {
          await cancelUseCase.execute(
            reservationId: reservationId,
            userId: userId,
            reason: reason ?? 'Cancelada por el usuario',
          );

          // Invalidar cache después de cancelar exitosamente
          cacheService.invalidateAfterCancel(reservationId);
        } catch (e) {
          // En caso de error, también invalidar cache por si quedó en estado inconsistente
          cacheService.invalidateCache(reason: 'Error al cancelar reserva: $e');
          rethrow;
        }
      };
    });

/// Provider para gestión completa de reservas del usuario
final userReservationManagementProvider = Provider.autoDispose
    .family<UserReservationManagement, String>((ref, userId) {
      final reservationsAsync = ref.watch(reservationsGlobalCacheProvider);
      final cacheService = ref.read(reservationCacheServiceProvider);

      return reservationsAsync.when(
        data: (allReservations) {
          final userReservations = cacheService.getUserReservationsFromCache(
            allReservations,
            userId,
          );

          // Separar por estado
          final confirmed = userReservations
              .where((r) => r.status == ReservationStatus.confirmed)
              .toList();
          final cancelled = userReservations
              .where((r) => r.status == ReservationStatus.cancelled)
              .toList();
          final completed = userReservations
              .where((r) => r.status == ReservationStatus.completed)
              .toList();

          // Separar confirmadas por tiempo
          final now = DateTime.now();
          final upcoming = confirmed
              .where((r) => r.startTime.isAfter(now))
              .toList();
          final today = confirmed.where((r) => r.isToday).toList();

          // Ordenar por fecha
          upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
          cancelled.sort((a, b) => b.startTime.compareTo(a.startTime));
          completed.sort((a, b) => b.startTime.compareTo(a.startTime));

          return UserReservationManagement(
            allReservations: userReservations,
            confirmedReservations: confirmed,
            upcomingReservations: upcoming,
            todayReservations: today,
            cancelledReservations: cancelled,
            completedReservations: completed,
            totalCount: userReservations.length,
            activeCount: confirmed.length,
          );
        },
        loading: () => UserReservationManagement.empty(),
        error: (_, __) => UserReservationManagement.empty(),
      );
    });

/// Gestión completa de reservas de un usuario
class UserReservationManagement {
  final List<Reservation> allReservations;
  final List<Reservation> confirmedReservations;
  final List<Reservation> upcomingReservations;
  final List<Reservation> todayReservations;
  final List<Reservation> cancelledReservations;
  final List<Reservation> completedReservations;
  final int totalCount;
  final int activeCount;

  const UserReservationManagement({
    required this.allReservations,
    required this.confirmedReservations,
    required this.upcomingReservations,
    required this.todayReservations,
    required this.cancelledReservations,
    required this.completedReservations,
    required this.totalCount,
    required this.activeCount,
  });

  /// Constructor para estado vacío/loading
  factory UserReservationManagement.empty() => const UserReservationManagement(
    allReservations: [],
    confirmedReservations: [],
    upcomingReservations: [],
    todayReservations: [],
    cancelledReservations: [],
    completedReservations: [],
    totalCount: 0,
    activeCount: 0,
  );

  /// Próxima reserva del usuario
  Reservation? get nextReservation {
    if (upcomingReservations.isEmpty) return null;
    return upcomingReservations.first;
  }

  /// Reservas que se pueden cancelar
  List<Reservation> get cancellableReservations {
    final now = DateTime.now();
    const minimumHours = 2;

    return confirmedReservations.where((r) {
      final deadline = r.startTime.subtract(
        const Duration(hours: minimumHours),
      );
      return now.isBefore(deadline);
    }).toList();
  }

  /// Estadísticas rápidas
  Map<String, int> get quickStats => {
    'total': totalCount,
    'active': activeCount,
    'upcoming': upcomingReservations.length,
    'today': todayReservations.length,
    'cancelled': cancelledReservations.length,
    'completed': completedReservations.length,
    'cancellable': cancellableReservations.length,
  };

  /// Mensaje de estado para mostrar al usuario
  String get statusMessage {
    if (todayReservations.isNotEmpty) {
      return 'Tienes ${todayReservations.length} reserva(s) hoy';
    } else if (upcomingReservations.isNotEmpty) {
      final next = upcomingReservations.first;
      return 'Próxima reserva: ${_formatDate(next.startTime)}';
    } else if (activeCount > 0) {
      return 'Tienes $activeCount reserva(s) activa(s)';
    } else {
      return 'No tienes reservas activas';
    }
  }

  /// Formatear fecha para mostrar al usuario
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
    return '${weekdays[date.weekday]}, ${date.day}/${date.month}';
  }
}
