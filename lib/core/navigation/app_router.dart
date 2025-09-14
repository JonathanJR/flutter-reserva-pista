import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/auth/views/login_view.dart';
import '../../presentation/auth/views/register_view.dart';
import '../../presentation/calendar/views/calendar_view.dart';
import '../../presentation/courts/views/court_list_view.dart';
import '../../presentation/home/views/home_view.dart';
import '../../presentation/profile/views/profile_view.dart';
import 'app_routes.dart';

/// Configuración del router de la aplicación
class AppRouter {
  static GoRouter get router => GoRouter(
    initialLocation: AppRoutes.initial.path,
    routes: [
      // Ruta de Login
      GoRoute(
        path: AppRoutes.login.path,
        name: AppRoutes.login.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginView(),
        ),
      ),
      
      // Ruta de Registro
      GoRoute(
        path: AppRoutes.register.path,
        name: AppRoutes.register.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const RegisterView(),
        ),
      ),
      
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

      // Ruta de Lista de Pistas
      GoRoute(
        path: '${AppRoutes.courtList.path}/:sportTypeId',
        name: AppRoutes.courtList.name,
        pageBuilder: (context, state) {
          final sportTypeId = state.pathParameters['sportTypeId']!;
          return MaterialPage(
            key: state.pageKey,
            child: CourtListView(sportTypeId: sportTypeId),
          );
        },
      ),

      // Ruta de Calendario
      GoRoute(
        path: '${AppRoutes.calendar.path}/:courtId/:courtName',
        name: AppRoutes.calendar.name,
        pageBuilder: (context, state) {
          final courtId = state.pathParameters['courtId']!;
          final safeCourtName = state.pathParameters['courtName']!;
          
          // Convertir de safe format a nombre legible
          final courtName = safeCourtName
              .replaceAll('_', ' '); // guiones bajos → espacios
          
          return MaterialPage(
            key: state.pageKey,
            child: CalendarView(
              courtId: courtId,
              courtName: courtName,
            ),
          );
        },
      ),
      
      // TODO: Agregar más rutas según sea necesario
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
