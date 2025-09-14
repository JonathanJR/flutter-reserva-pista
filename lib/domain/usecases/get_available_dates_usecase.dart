import '../repositories/remote_config_repository.dart';

/// Use case para obtener fechas disponibles para reservar
class GetAvailableDatesUseCase {
  final RemoteConfigRepository _remoteConfigRepository;

  const GetAvailableDatesUseCase(this._remoteConfigRepository);

  /// Obtener lista de fechas disponibles (solo días laborables)
  List<DateTime> execute() {
    final maxDaysAdvance = _remoteConfigRepository.getMaxDaysAdvance();
    final availableDates = <DateTime>[];
    final now = DateTime.now();
    
    // Empezar desde mañana
    var currentDate = DateTime(now.year, now.month, now.day + 1);
    var daysAdded = 0;
    
    while (daysAdded < maxDaysAdvance) {
      // Solo incluir días laborables (lunes a viernes)
      if (currentDate.weekday >= 1 && currentDate.weekday <= 5) {
        availableDates.add(currentDate);
        daysAdded++;
      }
      
      // Pasar al siguiente día
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return availableDates;
  }

  /// Formatear fecha para mostrar (ej: "Lun 15 Sep")
  static String formatDate(DateTime date) {
    final weekdays = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                   'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    
    final weekday = weekdays[date.weekday];
    final day = date.day;
    final month = months[date.month];
    
    return '$weekday\n$day\n$month';
  }

  /// Obtener nombre completo del mes en español
  static String getFullMonthName(int month) {
    const months = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                   'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month];
  }
}
