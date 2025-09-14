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
    final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
    final availableDates = availableDatesUseCase.execute();
    final debugInfo = remoteConfigRepository.getDebugInfo();
    
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
                    Text('Fuente: ${debugInfo['source_max_days_advance']}', style: const TextStyle(fontSize: 12)),
                    Text('Estado: ${debugInfo['lastFetchStatus']}', style: const TextStyle(fontSize: 12)),
                    if (debugInfo['lastFetchTime'] != null)
                      Text('Último fetch: ${debugInfo['lastFetchTime']}', style: const TextStyle(fontSize: 12)),
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
              
              // Card de seleccionar fecha
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Ícono de calendario
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Título de la card
                    Text(
                      selectedDate != null 
                          ? '${selectedDate!.day}'
                          : 'Selecciona una fecha',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtítulo de la card
                    Text(
                      selectedDate != null
                          ? 'Fecha seleccionada: ${_getFullDateString(selectedDate!)}'
                          : 'Elige una fecha disponible para ver los horarios',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF666666),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    if (selectedDate != null) ...[
                      const SizedBox(height: 24),
                      
                      // Botón para continuar (placeholder)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navegar a selección de horarios
                            debugPrint('Continuar con fecha: ${selectedDate}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text(
                            'Ver Horarios Disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
