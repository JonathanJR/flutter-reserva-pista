import 'package:firebase_remote_config/firebase_remote_config.dart';

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
      'morning_start_hour': 10,
      'morning_start_minute': 0,
      'morning_end_hour': 14,
      'morning_end_minute': 30,
      'afternoon_start_hour': 16,
      'afternoon_start_minute': 0,
      'afternoon_end_hour': 21,
      'afternoon_end_minute': 30,
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
    return {
      'start_hour': _remoteConfig.getInt('morning_start_hour'),
      'start_minute': _remoteConfig.getInt('morning_start_minute'),
      'end_hour': _remoteConfig.getInt('morning_end_hour'),
      'end_minute': _remoteConfig.getInt('morning_end_minute'),
    };
  }

  /// Obtener configuración de horarios vespertinos
  Map<String, int> getAfternoonConfig() {
    return {
      'start_hour': _remoteConfig.getInt('afternoon_start_hour'),
      'start_minute': _remoteConfig.getInt('afternoon_start_minute'),
      'end_hour': _remoteConfig.getInt('afternoon_end_hour'),
      'end_minute': _remoteConfig.getInt('afternoon_end_minute'),
    };
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
      'morning_start': '${_remoteConfig.getInt('morning_start_hour')}:${_remoteConfig.getInt('morning_start_minute').toString().padLeft(2, '0')}',
      'afternoon_start': '${_remoteConfig.getInt('afternoon_start_hour')}:${_remoteConfig.getInt('afternoon_start_minute').toString().padLeft(2, '0')}',
    };
  }
}
