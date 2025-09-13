/// Rutas de la aplicación
enum AppRoutes {
  home,
  profile,
  login,
  register,
  courtList;

  String get path => '/$name';
  String get name => toString().split('.').last;

  /// Ruta inicial de la aplicación
  static AppRoutes get initial => AppRoutes.home;
}
