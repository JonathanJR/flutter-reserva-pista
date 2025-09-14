import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
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
  
  @override
  Widget build(BuildContext context) {
    final availableDatesUseCase = ref.read(getAvailableDatesUseCaseProvider);
    final timeSlotsUseCase = ref.read(getTimeSlotsUseCaseProvider);
    final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
    final availableDates = availableDatesUseCase.execute();
    final debugInfo = remoteConfigRepository.getDebugInfo();
    
    // Generar slots de tiempo si hay una fecha seleccionada
    final dayTimeSlots = selectedDate != null ? timeSlotsUseCase.execute(selectedDate!) : null;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Calendario - ${widget.courtName}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                        Icon(Icons.settings, color: Colors.blue.shade700, size: 16),
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
                    Text('Días adelantados: ${debugInfo['max_days_advance']}', style: const TextStyle(fontSize: 12)),
                    Text('Duración reserva: ${debugInfo['reservation_duration_minutes']} min', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('🌅 Mañana: ${debugInfo['morning_start']} - ${debugInfo['morning_end']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text('🌆 Tarde: ${debugInfo['afternoon_start']} - ${debugInfo['afternoon_end']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
                    final isSelected = selectedDate != null && 
                        selectedDate!.day == date.day && 
                        selectedDate!.month == date.month && 
                        selectedDate!.year == date.year;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getWeekdayName(date.weekday),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getMonthName(date.month),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.grey.shade600,
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
                
                ...dayTimeSlots.morningSlots.map((slot) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        slot.displayTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onBackground,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: slot.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          slot.isAvailable ? 'Disponible' : 'Ocupado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: slot.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                
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
                
                ...dayTimeSlots.afternoonSlots.map((slot) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        slot.displayTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onBackground,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: slot.isAvailable ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          slot.isAvailable ? 'Disponible' : 'Ocupado',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: slot.isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ],
            
            const SizedBox(height: 32),
          ],
        ),
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
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month];
  }

  /// Obtener nombre completo de la fecha
  String _getFullDateString(DateTime date) {
    const weekdays = ['', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    
    final weekday = weekdays[date.weekday];
    final day = date.day;
    final month = months[date.month];
    final year = date.year;
    
    return '$weekday, $day de $month de $year';
  }

}
