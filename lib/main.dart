import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'presentation/home/views/home_view.dart';

void main() {
  runApp(const ReservaPistaApp());
}

class ReservaPistaApp extends StatelessWidget {
  const ReservaPistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva Pista',
      debugShowCheckedModeBanner: false,
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
      home: const HomeView(),
    );
  }
}
