import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(const ReservaPistaApp());
}

class ReservaPistaApp extends StatelessWidget {
  const ReservaPistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Reserva Pista',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          surfaceContainer: AppColors.background,
        ),
        useMaterial3: true,
      ),
    );
  }
}
