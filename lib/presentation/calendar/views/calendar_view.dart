import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/firebase_providers.dart';

/// Vista de selección de fecha para reservas
class CalendarView extends ConsumerStatefulWidget {
  final String courtId;
  final String courtName;

  const CalendarView({
    super.key,
    required this.courtId,
    required this.courtName,
  });

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime? selectedDate;
  DateTime? selectedTimeSlot; // Para guardar el slot de tiempo seleccionado

  @override
  Widget build(BuildContext context) {
    final availableDatesUseCase = ref.read(getAvailableDatesUseCaseProvider);
    final timeSlotsUseCase = ref.read(getTimeSlotsUseCaseProvider);
    final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
    final availableDates = availableDatesUseCase.execute();
    final debugInfo = remoteConfigRepository.getDebugInfo();

    // Generar slots de tiempo si hay una fecha seleccionada
    final dayTimeSlots = selectedDate != null
        ? timeSlotsUseCase.execute(selectedDate!)
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      // Para que la vista anclada no se mueva con el teclado
      appBar: AppBar(
        title: Text('Calendario - ${_cleanCourtName(widget.courtName)}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              selectedTimeSlot != null ? 140 : 16,
            ),
            // Padding extra si hay slot seleccionado
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                const Text(
                  'Selecciona fecha y horario:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtítulo explicativo
                const Text(
                  'Escoge un día disponible y luego selecciona el horario que prefieras.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                // Información de Remote Config (solo en debug)
                if (kDebugMode) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.blue.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remote Config Debug',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Días adelantados: ${debugInfo['max_days_advance']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Duración reserva: ${debugInfo['reservation_duration_minutes']} min',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '🌅 Mañana: ${debugInfo['morning_start']} - ${debugInfo['morning_end']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '🌆 Tarde: ${debugInfo['afternoon_start']} - ${debugInfo['afternoon_end']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sección de fechas disponibles
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Fechas disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Lista horizontal de fechas disponibles
                if (availableDates.isNotEmpty) ...[
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableDates.length,
                      itemBuilder: (context, index) {
                        final date = availableDates[index];
                        final isSelected =
                            selectedDate != null &&
                            selectedDate!.day == date.day &&
                            selectedDate!.month == date.month &&
                            selectedDate!.year == date.year;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                              selectedTimeSlot =
                                  null; // Limpiar slot seleccionado al cambiar fecha
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getWeekdayName(date.weekday),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getMonthName(date.month),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Card informativa si no hay fecha seleccionada
                  if (selectedDate == null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey.shade600,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Información',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Por favor, selecciona una fecha de las opciones disponibles para ver los horarios de reserva.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else ...[
                  // Mensaje si no hay fechas disponibles
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay fechas disponibles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Por favor, intenta más tarde o contacta con el administrador.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],

                // Mostrar horarios disponibles si hay una fecha seleccionada
                if (selectedDate != null && dayTimeSlots != null) ...[
                  const SizedBox(height: 32),

                  // Sección de horarios disponibles
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Horarios disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Fecha seleccionada
                  Text(
                    'Fecha seleccionada: ${_getFullDateString(selectedDate!)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Horarios de mañana
                  if (dayTimeSlots.morningSlots.isNotEmpty) ...[
                    Text(
                      'Mañana',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...dayTimeSlots.morningSlots.map(
                      (slot) => GestureDetector(
                        onTap: slot.isAvailable
                            ? () {
                                setState(() {
                                  selectedTimeSlot = slot.startTime;
                                });
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                selectedTimeSlot?.isAtSameMomentAs(
                                      slot.startTime,
                                    ) ==
                                    true
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selectedTimeSlot?.isAtSameMomentAs(
                                        slot.startTime,
                                      ) ==
                                      true
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                slot.displayTime,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      selectedTimeSlot?.isAtSameMomentAs(
                                            slot.startTime,
                                          ) ==
                                          true
                                      ? Colors.white
                                      : AppColors.onBackground,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selectedTimeSlot?.isAtSameMomentAs(
                                            slot.startTime,
                                          ) ==
                                          true
                                      ? Colors.white.withOpacity(0.3)
                                      : slot.isAvailable
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  slot.isAvailable ? 'Disponible' : 'Ocupado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        selectedTimeSlot?.isAtSameMomentAs(
                                              slot.startTime,
                                            ) ==
                                            true
                                        ? Colors.white
                                        : slot.isAvailable
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],

                  // Horarios de tarde
                  if (dayTimeSlots.afternoonSlots.isNotEmpty) ...[
                    Text(
                      'Tarde',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...dayTimeSlots.afternoonSlots.map(
                      (slot) => GestureDetector(
                        onTap: slot.isAvailable
                            ? () {
                                setState(() {
                                  selectedTimeSlot = slot.startTime;
                                });
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                selectedTimeSlot?.isAtSameMomentAs(
                                      slot.startTime,
                                    ) ==
                                    true
                                ? AppColors.primary
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  selectedTimeSlot?.isAtSameMomentAs(
                                        slot.startTime,
                                      ) ==
                                      true
                                  ? AppColors.primary
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                slot.displayTime,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      selectedTimeSlot?.isAtSameMomentAs(
                                            slot.startTime,
                                          ) ==
                                          true
                                      ? Colors.white
                                      : AppColors.onBackground,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      selectedTimeSlot?.isAtSameMomentAs(
                                            slot.startTime,
                                          ) ==
                                          true
                                      ? Colors.white.withOpacity(0.3)
                                      : slot.isAvailable
                                      ? Colors.green.shade100
                                      : Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  slot.isAvailable ? 'Disponible' : 'Ocupado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        selectedTimeSlot?.isAtSameMomentAs(
                                              slot.startTime,
                                            ) ==
                                            true
                                        ? Colors.white
                                        : slot.isAvailable
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),

          // Vista anclada en la parte inferior cuando hay un slot seleccionado
          if (selectedTimeSlot != null && selectedDate != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reserva seleccionada:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_cleanCourtName(widget.courtName)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getFullDateString(selectedDate!)} • ${_formatSelectedTimeSlot(selectedTimeSlot!)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _navigateToConfirmReservation(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Obtener nombre del día de la semana
  String _getWeekdayName(int weekday) {
    const weekdays = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return weekdays[weekday];
  }

  /// Obtener nombre del mes abreviado
  String _getMonthName(int month) {
    const months = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return months[month];
  }

  /// Obtener nombre completo de la fecha
  String _getFullDateString(DateTime date) {
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

    final weekday = weekdays[date.weekday];
    final day = date.day;
    final month = months[date.month];
    final year = date.year;

    return '$weekday, $day de $month de $year';
  }

  /// Formatear slot de tiempo seleccionado para mostrar
  String _formatSelectedTimeSlot(DateTime timeSlot) {
    final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
    final durationMinutes = remoteConfigRepository
        .getReservationDurationMinutes();
    final endTime = timeSlot.add(Duration(minutes: durationMinutes));

    final start =
        '${timeSlot.hour.toString().padLeft(2, '0')}:${timeSlot.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return '$start-$end';
  }

  /// Navegar a la vista de confirmación de reserva
  void _navigateToConfirmReservation(BuildContext context) {
    if (selectedDate != null && selectedTimeSlot != null) {
      // Limpiar y preparar parámetros para la navegación
      final cleanCourtName = _cleanCourtName(widget.courtName);
      final safeCourtName = cleanCourtName
          .replaceAll(' ', '_')
          .replaceAll('-', '_');

      // Formatear fecha completa
      final fullDateString = _getFullDateString(selectedDate!);

      // Formatear horario seleccionado
      final timeSlotString = _formatSelectedTimeSlot(selectedTimeSlot!);

      // Codificar parámetros para URL
      final encodedDate = Uri.encodeComponent(fullDateString);
      final encodedTime = Uri.encodeComponent(timeSlotString);

      // Navegar a confirmación de reserva
      context.push(
        '${AppRoutes.confirmReservation.path}/${widget.courtId}/$safeCourtName/$encodedDate/$encodedTime',
      );
    }
  }

  /// Limpiar espacios extra del nombre de la pista
  String _cleanCourtName(String name) {
    return name
        .split(' ') // Dividir por espacios
        .where((word) => word.isNotEmpty) // Filtrar strings vacíos
        .join(' '); // Unir con un solo espacio
  }
}
