import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../common/widgets/sport_card.dart';
import '../state/home_state.dart';

/// Vista principal de la pantalla Home
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener el estado inicial con los deportes
    final homeState = HomeState.initial();
    
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
      body: SingleChildScrollView(
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
              
              // Tarjetas de deportes dinámicas desde el estado
              ...homeState.sports.map((sport) => SportCard(
                title: sport.name,
                imagePath: sport.imagePath,
                isAvailable: sport.isAvailable,
                onTap: () {
                  // TODO: Navegar a opciones según el deporte
                  debugPrint('Tapped on ${sport.name} (${sport.id})');
                },
              )),
              
              // Espaciado inferior para mejor UX
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
