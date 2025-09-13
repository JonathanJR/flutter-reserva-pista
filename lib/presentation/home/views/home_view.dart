import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../debug/firestore_test_data.dart';
import '../../common/widgets/sport_card.dart';

/// Vista principal de la pantalla Home
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar el provider de sport types con disponibilidad real
    final sportTypesAsync = ref.watch(sportTypesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Polideportivo Gilena',
          style: TextStyle(
            color: AppColors.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Botón de debug solo en modo debug
          if (kDebugMode)
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.settings,
                color: AppColors.onPrimary,
              ),
              onSelected: (value) async {
                switch (value) {
                  case 'verify_connection':
                    await FirestoreTestData.verifyFirestoreConnection();
                    break;
                  case 'toggle_tennis':
                    await FirestoreTestData.toggleSportTypeAvailability('tennis');
                    // Con streams, no necesitamos refresh manual - se actualiza automáticamente
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🎾 Estado de Tenis cambiado - Actualizando en tiempo real ⚡')),
                      );
                    }
                    break;
                  case 'toggle_padel':
                    await FirestoreTestData.toggleSportTypeAvailability('padel');
                    // Con streams, no necesitamos refresh manual - se actualiza automáticamente
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🏓 Estado de Pádel cambiado - Actualizando en tiempo real ⚡')),
                      );
                    }
                    break;
                  case 'toggle_football':
                    await FirestoreTestData.toggleSportTypeAvailability('football');
                    // Con streams, no necesitamos refresh manual - se actualiza automáticamente
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚽ Estado de Fútbol Sala cambiado - Actualizando en tiempo real ⚡')),
                      );
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'verify_connection',
                  child: Text('🔍 Verificar conexión'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'toggle_tennis',
                  child: Text('🎾 Toggle Tenis'),
                ),
                const PopupMenuItem(
                  value: 'toggle_padel',
                  child: Text('🏓 Toggle Pádel'),
                ),
                const PopupMenuItem(
                  value: 'toggle_football',
                  child: Text('⚽ Toggle Fútbol Sala'),
                ),
              ],
            ),
          IconButton(
            onPressed: () {
              context.push(AppRoutes.profile.path);
            },
            icon: const Icon(
              Icons.person,
              color: AppColors.onPrimary,
            ),
          ),
        ],
      ),
      body: sportTypesAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                'Cargando pistas disponibles...',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
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
                'Error al cargar las pistas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(sportTypesProvider),
                            child: const Text('Reintentar'),
                          ),
            ],
          ),
        ),
        data: (sportTypes) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de bienvenida
                const Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtítulo
                const Text(
                  'Selecciona el tipo de pista que deseas reservar:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Mostrar mensaje si no hay pistas disponibles
                if (sportTypes.isEmpty)
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.sports_soccer_outlined,
                          size: 64,
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
                  )
                else
                  // Tarjetas de deportes con datos reales de Firestore
                  ...sportTypes.map((sportType) => SportCard(
                    title: sportType.name,
                    imagePath: sportType.imagePath,
                    isAvailable: sportType.isAvailable,
                    onTap: () {
                      if (sportType.isAvailable) {
                        // TODO: Navegar a selección de pistas específicas
                        debugPrint('Tapped on ${sportType.name} (${sportType.id})');
                      } else {
                        // Mostrar mensaje de no disponible
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'No hay pistas de ${sportType.name} disponibles en este momento',
                            ),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    },
                  )),
                
                // Espaciado inferior para mejor UX
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
