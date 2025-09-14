/// Repository para configuraciones remotas
abstract interface class RemoteConfigRepository {
  /// Inicializar configuraciones remotas
  Future<void> initialize();

  /// Obtener número máximo de días de anticipación para reservas
  int getMaxDaysAdvance();

  /// Obtener valor booleano
  bool getBool(String key);

  /// Obtener valor entero
  int getInt(String key);

  /// Obtener valor double
  double getDouble(String key);

  /// Obtener valor string
  String getString(String key);

  /// Forzar actualización de configuraciones
  Future<bool> forceRefresh();
  
  /// Obtener información de debug
  Map<String, dynamic> getDebugInfo();
}
