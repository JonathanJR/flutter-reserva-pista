import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Datasource para Firebase Remote Config
class RemoteConfigDataSource {
  final FirebaseRemoteConfig _remoteConfig;

  const RemoteConfigDataSource(this._remoteConfig);

  /// Inicializar Remote Config con valores por defecto
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: Duration.zero, // Sin intervalo mínimo para siempre obtener valores frescos
      ),
    );

    // Establecer valores por defecto
    await _remoteConfig.setDefaults({
      'max_days_advance': 7,
      'morning_start_hour': '10:00',
      'morning_end_hour': '14:30', 
      'afternoon_start_hour': '16:00',
      'afternoon_end_hour': '21:30',
      'reservation_duration_minutes': 90,
    });

    // SIEMPRE fetch y activar configuración remota cada vez que se inicia la app
    await _remoteConfig.fetchAndActivate();
  }

  /// Obtener el número máximo de días de anticipación para reservas
  int getMaxDaysAdvance() {
    return _remoteConfig.getInt('max_days_advance');
  }

  /// Obtener valor booleano de Remote Config
  bool getBool(String key) {
    return _remoteConfig.getBool(key);
  }

  /// Obtener valor entero de Remote Config
  int getInt(String key) {
    return _remoteConfig.getInt(key);
  }

  /// Obtener valor double de Remote Config
  double getDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  /// Obtener valor string de Remote Config
  String getString(String key) {
    return _remoteConfig.getString(key);
  }

  /// Forzar actualización de configuración remota
  Future<bool> forceRefresh() async {
    try {
      final result = await _remoteConfig.fetchAndActivate();
      return result; // true si se obtuvieron nuevos valores
    } catch (e) {
      print('Error al refrescar Remote Config: $e');
      return false;
    }
  }

  /// Obtener configuración de horarios matutinos
  Map<String, int> getMorningConfig() {
    final startTime = _parseTimeString(_remoteConfig.getString('morning_start_hour'));
    final endTime = _parseTimeString(_remoteConfig.getString('morning_end_hour'));
    
    return {
      'start_hour': startTime['hour']!,
      'start_minute': startTime['minute']!,
      'end_hour': endTime['hour']!,
      'end_minute': endTime['minute']!,
    };
  }

  /// Obtener configuración de horarios vespertinos
  Map<String, int> getAfternoonConfig() {
    final startTime = _parseTimeString(_remoteConfig.getString('afternoon_start_hour'));
    final endTime = _parseTimeString(_remoteConfig.getString('afternoon_end_hour'));
    
    return {
      'start_hour': startTime['hour']!,
      'start_minute': startTime['minute']!,
      'end_hour': endTime['hour']!,
      'end_minute': endTime['minute']!,
    };
  }

  /// Parsear string de tiempo formato "HH:mm" a Map con hour y minute
  Map<String, int> _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) {
        throw FormatException('Formato de tiempo inválido: $timeString');
      }
      
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      
      // Validar rango de horas y minutos
      if (hour < 0 || hour > 23) {
        throw FormatException('Hora inválida: $hour');
      }
      if (minute < 0 || minute > 59) {
        throw FormatException('Minuto inválido: $minute');
      }
      
      return {
        'hour': hour,
        'minute': minute,
      };
    } catch (e) {
      // Si hay error en el parsing, usar valores por defecto seguros
      debugPrint('Error parseando tiempo "$timeString": $e. Usando 10:00 como fallback.');
      return {
        'hour': 10,
        'minute': 0,
      };
    }
  }

  /// Obtener duración de reserva en minutos
  int getReservationDurationMinutes() {
    return _remoteConfig.getInt('reservation_duration_minutes');
  }

  /// Obtener información de Remote Config para debugging
  Map<String, dynamic> getDebugInfo() {
    return {
      'lastFetchTime': _remoteConfig.lastFetchTime,
      'lastFetchStatus': _remoteConfig.lastFetchStatus.toString(),
      'max_days_advance': _remoteConfig.getInt('max_days_advance'),
      'source_max_days_advance': _remoteConfig.getValue('max_days_advance').source.toString(),
      'reservation_duration_minutes': _remoteConfig.getInt('reservation_duration_minutes'),
      'morning_start': _remoteConfig.getString('morning_start_hour'),
      'morning_end': _remoteConfig.getString('morning_end_hour'),
      'afternoon_start': _remoteConfig.getString('afternoon_start_hour'),
      'afternoon_end': _remoteConfig.getString('afternoon_end_hour'),
    };
  }
}
