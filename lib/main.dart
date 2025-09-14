import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/navigation/app_router.dart';
import 'core/providers/firebase_providers.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    // Envolver con ProviderScope para Riverpod
    const ProviderScope(
      child: ReservaPistaApp(),
    ),
  );
}

class ReservaPistaApp extends ConsumerWidget {
  const ReservaPistaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _initializeRemoteConfig(ref),
      builder: (context, snapshot) {
        // Mostrar splash screen mientras se inicializa Remote Config
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.primary,
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_tennis,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Polideportivo Gilena',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            debugShowCheckedModeBanner: false,
          );
        }

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
      },
    );
  }

  /// Inicializar Remote Config
  Future<void> _initializeRemoteConfig(WidgetRef ref) async {
    try {
      final remoteConfigRepository = ref.read(remoteConfigRepositoryProvider);
      await remoteConfigRepository.initialize();
      
      final debugInfo = remoteConfigRepository.getDebugInfo();
      debugPrint('🔥 Remote Config inicializado correctamente');
      debugPrint('📊 max_days_advance: ${debugInfo['max_days_advance']}');
      debugPrint('📡 Fuente: ${debugInfo['source_max_days_advance']}');
      debugPrint('⏰ Estado: ${debugInfo['lastFetchStatus']}');
    } catch (e) {
      // Si falla la inicialización de Remote Config, continuar con valores por defecto
      debugPrint('❌ Error inicializando Remote Config: $e');
    }
  }
}
