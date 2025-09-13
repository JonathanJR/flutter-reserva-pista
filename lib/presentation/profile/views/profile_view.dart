import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Vista de la pantalla de Perfil
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espaciador superior
              const Spacer(),
              
              // Tarjeta principal de login
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D5FF), // Color morado claro como en la imagen
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
                          // TODO: Implementar navegación a pantalla de login
                          debugPrint('Iniciar Sesión pressed');
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
              
              // Espaciador inferior
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
