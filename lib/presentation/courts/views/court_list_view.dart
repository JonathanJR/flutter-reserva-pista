import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../domain/models/sport_type.dart';

/// Vista para mostrar las pistas específicas de un deporte
class CourtListView extends ConsumerWidget {
  final String sportTypeId;
  
  const CourtListView({
    super.key,
    required this.sportTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courtsAsync = ref.watch(courtsBySportTypeProvider(sportTypeId));
    final authState = ref.watch(authStateProvider);
    final sportType = SportType.fromId(sportTypeId);
    
    // Verificar si el usuario está loggeado
    final isUserLoggedIn = authState.when(
      data: (user) => user != null,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Opciones de ${sportType?.displayName ?? 'Deporte'}'),
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
              'Selecciona la pista específica:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Subtítulo explicativo
            const Text(
              'Cada opción tiene características diferentes. Elige la que mejor se adapte a tus necesidades.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Card informativa si el usuario NO está loggeado
            if (!isUserLoggedIn) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '¿Quieres hacer una reserva?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Puedes ver la disponibilidad sin registrarte, pero necesitas una cuenta para realizar reservas.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botón Iniciar Sesión / Registrarse
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(AppRoutes.login.path);
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
                          'Iniciar Sesión / Registrarse',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
            ],
            
            // Lista de pistas
            courtsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar las pistas: $error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
              data: (courts) {
                if (courts.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.sports_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay pistas disponibles en este momento',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: courts.map((court) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila superior con icono e información
                        Row(
                          children: [
                            // Icono de la pista
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                _getSportIcon(sportTypeId),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Información de la pista
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pista ${court.displayName}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  
                                  Text(
                                    _getCourtDescription(court),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botón Ver Disponibilidad - Ancho completo
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              // TODO: Implementar navegación a disponibilidad
                              debugPrint('Ver disponibilidad de pista');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Ver Disponibilidad',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Obtener ícono según el tipo de deporte
  IconData _getSportIcon(String sportTypeId) {
    switch (sportTypeId) {
      case 'tennis':
        return Icons.sports_tennis;
      case 'padel':
        return Icons.sports_tennis; // No hay ícono específico de pádel
      case 'football':
        return Icons.sports_soccer;
      default:
        return Icons.sports;
    }
  }

  /// Obtener descripción de la pista
  String _getCourtDescription(court) {
    switch (court.courtType) {
      case 'tennis':
        if (court.specificOption == 'pasillo') {
          return 'Pista de tenis situada junto al pasillo del polideportivo';
        } else if (court.specificOption == 'piscina') {
          return 'Pista de tenis situada junto a la piscina';
        }
        break;
      case 'padel':
        if (court.specificOption == 'cemento') {
          return 'Pista de pádel con suelo de cemento';
        } else if (court.specificOption == 'cristal') {
          return 'Pista de pádel con paredes de cristal';
        }
        break;
      case 'football':
        if (court.specificOption == 'exterior') {
          return 'Pista de fútbol sala exterior';
        } else if (court.specificOption == 'interior') {
          return 'Pista de fútbol sala interior';
        }
        break;
    }
    return 'Pista disponible para reservar';
  }
}
