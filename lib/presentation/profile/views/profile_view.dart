import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/firebase_providers.dart';

/// Vista de la pantalla de Perfil
class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.onPrimary,
          ),
        ),
      ),
      body: authState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => const Center(
          child: Text('Error al cargar el perfil'),
        ),
        data: (user) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Espaciador superior
                const Spacer(),
                
                if (user == null) ...[
                  // Usuario no autenticado - Mostrar tarjeta de login
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono de usuario
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.onPrimary,
                            size: 48,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Título principal
                        const Text(
                          'Inicia sesión',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69), // Color morado oscuro
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Descripción
                        const Text(
                          'Accede a tu cuenta para gestionar tus reservas y ver tu historial de actividades',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF666666),
                            height: 1.4,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botón de Iniciar Sesión
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(AppRoutes.login.path);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Usuario autenticado - Mostrar información del perfil
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tarjeta principal del perfil
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Avatar con iniciales
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: Text(
                                  _getInitials(user.fullName),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Nombre del usuario
                            Text(
                              user.fullName.isNotEmpty ? user.fullName : user.displayName ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D1B69), // Morado oscuro
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Email del usuario
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF666666),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Botón Editar perfil
                            SizedBox(
                              width: 200,
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Implementar editar perfil
                                  debugPrint('Editar perfil pressed');
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Color(0xFF2D1B69),
                                ),
                                label: const Text(
                                  'Editar perfil',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D1B69),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF2D1B69), width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Título Estadísticas
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Estadísticas',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tarjetas de estadísticas
                      Row(
                        children: [
                          // Total reservas
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 16, right: 8),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.green.shade600,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${user.reservationCount}',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total reservas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Reservas activas
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 16),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.green.shade600,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Activas',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Miembro desde
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Miembro desde',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRegistrationDate(user.registrationDate),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botón de Cerrar Sesión
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final authRepository = ref.read(authRepositoryProvider);
                            await authRepository.signOut();
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                // Espaciador inferior
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Obtener iniciales del nombre completo
  String _getInitials(String fullName) {
    if (fullName.isEmpty) return 'U';
    
    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    } else {
      return '${names[0].substring(0, 1)}${names[1].substring(0, 1)}'.toUpperCase();
    }
  }

  /// Formatear fecha de registro
  String _formatRegistrationDate(DateTime date) {
    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    final day = date.day;
    final month = months[date.month];
    final year = date.year;
    
    return '$day de $month del $year';
  }
}
