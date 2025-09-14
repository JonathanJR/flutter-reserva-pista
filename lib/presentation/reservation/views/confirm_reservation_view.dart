import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/firebase_providers.dart';

/// Vista de confirmación de reserva
class ConfirmReservationView extends ConsumerStatefulWidget {
  final String courtId;
  final String courtName;
  final String selectedDate;
  final String selectedTime;

  const ConfirmReservationView({
    super.key,
    required this.courtId,
    required this.courtName,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  ConsumerState<ConfirmReservationView> createState() =>
      _ConfirmReservationViewState();
}

class _ConfirmReservationViewState
    extends ConsumerState<ConfirmReservationView> {
  bool _isCreatingReservation = false;

  @override
  Widget build(BuildContext context) {
    final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
    final durationMinutes = remoteConfigRepository
        .getReservationDurationMinutes();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmar Reserva'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
        ),
      ),
      body: Column(
        children: [
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección superior morada con confirmación
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Icono de check verde
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Título principal
                        const Text(
                          '¡Lista para confirmar!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69), // Morado oscuro
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Descripción
                        const Text(
                          'Revisa los detalles de tu reserva antes de confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Título de detalles
                  const Text(
                    'Detalles de la reserva:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta de pista seleccionada
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Icono con check verde
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Información de la pista
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pista seleccionada',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getSportAndCourtName(widget.courtName),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Polideportivo Municipal de Gilena',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tarjeta de fecha y horario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Icono de calendario verde
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Colors.green.shade700,
                            size: 24,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Información de fecha y horario
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Fecha y horario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.selectedDate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.selectedTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Duración: ${_formatDuration(durationMinutes)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tarjeta de precio
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Precio total',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onBackground,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reserva municipal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Gratuito',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Condiciones importantes
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Condiciones importantes:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        ..._getReservationConditions().map(
                          (condition) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    condition,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Botones inferiores
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Botón Confirmar Reserva
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isCreatingReservation
                            ? null
                            : () => _confirmReservation(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isCreatingReservation
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.onPrimary,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Procesando...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Confirmar Reserva',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirmar reserva usando el cache provider
  Future<void> _confirmReservation(BuildContext context) async {
    // Obtener información del usuario actual
    final authState = ref.read(authStateProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      _showErrorDialog(
        context,
        'Error',
        'Debes iniciar sesión para hacer una reserva',
      );
      return;
    }

    try {
      setState(() {
        _isCreatingReservation = true;
      });

      // Parsear fecha y hora desde los strings recibidos
      final startDateTime = _parseDateTime(
        widget.selectedDate,
        widget.selectedTime,
      );
      final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
      final durationMinutes = remoteConfigRepository
          .getReservationDurationMinutes();
      final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

      // Usar el provider con cache para crear la reserva
      final createReservationFunction = ref.read(
        createReservationWithCacheProvider,
      );

      final reservationId = await createReservationFunction(
        userId: user.id,
        courtId: widget.courtId,
        courtName: widget.courtName,
        startTime: startDateTime,
        endTime: endDateTime,
      );

      if (mounted) {
        _showConfirmationDialog(context, reservationId);
      }
    } catch (error) {
      if (mounted) {
        _showErrorDialog(
          context,
          'Error al crear reserva',
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingReservation = false;
        });
      }
    }
  }

  /// Parsear fecha y hora desde strings
  DateTime _parseDateTime(String dateString, String timeString) {
    try {
      // Parsear fecha - puede ser con o sin año:
      // Formato 1: "Miércoles, 15 de Enero" (sin año)
      // Formato 2: "Martes, 16 de Septiembre de 2025" (con año)
      final now = DateTime.now();
      final parts = dateString.split(', ');

      if (parts.length != 2) {
        throw FormatException('Formato de fecha inválido: $dateString');
      }

      final dayMonthYearPart =
          parts[1]; // "15 de Enero" o "16 de Septiembre de 2025"
      final dayMonthYearParts = dayMonthYearPart.split(' de ');

      // Verificar si tiene año (3 partes) o no (2 partes)
      int day, month, year;
      String monthName;

      if (dayMonthYearParts.length == 2) {
        // Formato sin año: "15 de Enero"
        day = int.parse(dayMonthYearParts[0]);
        monthName = dayMonthYearParts[1];

        // Mapear nombre del mes a número
        final monthMap = {
          'Enero': 1,
          'Febrero': 2,
          'Marzo': 3,
          'Abril': 4,
          'Mayo': 5,
          'Junio': 6,
          'Julio': 7,
          'Agosto': 8,
          'Septiembre': 9,
          'Octubre': 10,
          'Noviembre': 11,
          'Diciembre': 12,
        };

        final monthNumber = monthMap[monthName];
        if (monthNumber == null) {
          throw FormatException('Nombre de mes inválido: $monthName');
        }

        month = monthNumber;

        // Usar el año actual, pero si el mes es menor al actual, usar el año siguiente
        year = now.year;
        if (month < now.month || (month == now.month && day < now.day)) {
          year += 1;
        }
      } else if (dayMonthYearParts.length == 3) {
        // Formato con año: "16 de Septiembre de 2025"
        day = int.parse(dayMonthYearParts[0]);
        monthName = dayMonthYearParts[1];
        year = int.parse(dayMonthYearParts[2]);

        // Mapear nombre del mes a número
        final monthMap = {
          'Enero': 1,
          'Febrero': 2,
          'Marzo': 3,
          'Abril': 4,
          'Mayo': 5,
          'Junio': 6,
          'Julio': 7,
          'Agosto': 8,
          'Septiembre': 9,
          'Octubre': 10,
          'Noviembre': 11,
          'Diciembre': 12,
        };

        final monthNumber = monthMap[monthName];
        if (monthNumber == null) {
          throw FormatException('Nombre de mes inválido: $monthName');
        }

        month = monthNumber;
      } else {
        throw FormatException(
          'Formato de fecha inválido: $dateString - Se esperaba "Día, DD de Mes" o "Día, DD de Mes de YYYY"',
        );
      }

      // Parsear hora - puede ser con o sin espacios:
      // Formato 1: "10:00 - 11:30" (con espacios)
      // Formato 2: "11:30-13:00" (sin espacios)
      List<String> timeParts;

      if (timeString.contains(' - ')) {
        // Formato con espacios: "10:00 - 11:30"
        timeParts = timeString.split(' - ');
      } else if (timeString.contains('-')) {
        // Formato sin espacios: "11:30-13:00"
        timeParts = timeString.split('-');
      } else {
        throw FormatException(
          'Formato de hora inválido: $timeString - Se esperaba formato "HH:MM-HH:MM" o "HH:MM - HH:MM"',
        );
      }

      if (timeParts.length != 2) {
        throw FormatException(
          'Formato de hora inválido: $timeString - Se esperaba hora de inicio y fin',
        );
      }

      final startTimePart = timeParts[0].trim(); // "10:00" o "11:30"
      final hourMinuteParts = startTimePart.split(':');

      if (hourMinuteParts.length != 2) {
        throw FormatException(
          'Formato de hora inválido: $timeString - Formato de hora de inicio inválido',
        );
      }

      final hour = int.parse(hourMinuteParts[0]);
      final minute = int.parse(hourMinuteParts[1]);

      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      throw FormatException(
        'Error al parsear fecha/hora: $dateString, $timeString. Error: $e',
      );
    }
  }

  /// Mostrar diálogo de error
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendido',
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtener nombre del deporte y pista
  String _getSportAndCourtName(String courtName) {
    // Limpiar espacios extra del nombre
    final cleanName = _cleanCourtName(courtName);

    // El courtName ya viene con el formato correcto desde el modelo Court
    // Solo necesitamos limpiar espacios extra, no agregar prefijos duplicados
    return cleanName;
  }

  /// Limpiar espacios extra del nombre de la pista
  String _cleanCourtName(String name) {
    return name
        .split(' ') // Dividir por espacios
        .where((word) => word.isNotEmpty) // Filtrar strings vacíos
        .join(' '); // Unir con un solo espacio
  }

  /// Formatear duración en minutos
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}min';
    }
  }

  /// Obtener condiciones de la reserva
  List<String> _getReservationConditions() {
    return [
      'La reserva tiene una duración fija de 1h 30min',
      'Puedes cancelar la reserva hasta 2 horas antes del horario programado',
      'Máximo 1 reserva activa por día',
      'Debes llegar puntual al horario reservado',
      'Trae tu propio equipamiento deportivo',
    ];
  }

  /// Mostrar diálogo de confirmación
  void _showConfirmationDialog(BuildContext context, String reservationId) {
    showDialog(
      context: context,
      barrierDismissible: false, // No permitir cerrar tocando fuera
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '¡Reserva Confirmada!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tu reserva ha sido creada exitosamente:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 ${_getSportAndCourtName(widget.courtName)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📅 ${widget.selectedDate}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🕐 ${widget.selectedTime}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${reservationId.substring(0, 8)}...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Puedes ver y gestionar tus reservas desde tu perfil.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              context.go('/profile'); // Ir al perfil para ver las reservas
            },
            child: Text(
              'Ver Perfil',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar diálogo
              context.go('/'); // Navegar a home
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ir a Inicio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
