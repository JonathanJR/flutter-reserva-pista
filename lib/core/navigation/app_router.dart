import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/home/views/home_view.dart';
import '../../presentation/profile/views/profile_view.dart';
import 'app_routes.dart';

/// Configuración del router de la aplicación
class AppRouter {
  static GoRouter get router => GoRouter(
    initialLocation: AppRoutes.initial.path,
    routes: [
      // Ruta de Home
      GoRoute(
        path: AppRoutes.home.path,
        name: AppRoutes.home.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeView(),
        ),
      ),
      
      // Ruta de Perfil
      GoRoute(
        path: AppRoutes.profile.path,
        name: AppRoutes.profile.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfileView(),
        ),
      ),
      
      // TODO: Agregar más rutas según sea necesario
      // - Login
      // - Register
      // - Court Selection
      // - Calendar
      // - Reservations
    ],
    
    // Manejo de errores de navegación
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Página no encontrada',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home.path),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
