import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rm_app_flutter_core/application/startup/providers/providers.dart';
import 'package:rm_app_flutter_core/core/logger/global_logger.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/application/providers/domain_events_provider.dart';
import 'package:rm_app_flutter_fan/core/providers/one_trust_provider.dart';
import 'package:rm_app_flutter_fan/domain/events/startup/startup_events.dart';

final appStartupProvider = FutureProvider<void>(
  (ref) async {
    await _setOrientation();
    //final environment = ref.watch(environmentProvider);

    //await _initializeAemDictionary(ref);
    //await _initializeFirebase(environment);
    //await _initializeFlutterDownloader();
   // _initializeErrorHandlers(environment);
    //await _initializeAnalytics(environment);
    //await _initializeBiometric(ref);
    //await _initializeLegalTexts(ref);

    try {
      ref
          .read(domainEventObserverProvider)
          .initializeEventSubscribers(ref.container);

      ref.read(oneTrustManagerListenerProvider);      
      ref.read(eventBusProvider).publish(AppStartupCompleted());
    } catch (e) {
      logError('Error initializing app', error: e);
      ref.read(eventBusProvider).publish(AppStartupFailed(e.toString()));
    }
    
    //await ref.read(indigitallProvider).requestNotificationPermission();
    await ref.read(oneTrustProvider).showBannerUIIfNeeded();
  },
);

// Future<void> _initializeAemDictionary(Ref ref) async {
//   final dataSource = ref.read(dictionaryDataSourceProvider);
//   final result = await dataSource.fetchDictionary(
//     language: ref.langCountryCode,
//   );

//   result.when(
//     (dictionary) {
//       ref.read(dictionaryProvider.notifier).state = dictionary;
//       logInfo(
//         'Dictionary loaded successfully for language: ${ref.langCountryCode}',
//       );
//     },
//     (exception) {
//       logError('Failed to load dictionary', error: exception);
//     },
//   );
// }

Future<void> _setOrientation() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

// Future<void> _initializeFlutterDownloader() async {
//   await FlutterDownloader.initialize();
// }

// Future<void> _initializeFirebase(Environment environment) async {
//   // final options = switch (environment) {
//   //   Environment.development => FirebaseOptionsDev.currentPlatform,
//   //   Environment.staging => FirebaseOptionsStg.currentPlatform,
//   //   Environment.production => FirebaseOptionsPrd.currentPlatform,
//   //   Environment.mock => FirebaseOptionsDev.currentPlatform,
//   // };

//   // await Firebase.initializeApp(options: options);
//   // logDebug('Firebase initialized [${options.appId}]');
// }

// void _initializeErrorHandlers(Environment environment) {
//   FlutterError.onError = (errorDetails) {
//     if (kReleaseMode && !environment.isDevelopment) {
//       FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
//     } else {
//       logError(
//         'Fatal Error',
//         error: errorDetails.exception,
//         stackTrace: errorDetails.stack,
//       );
//     }
//   };

//   PlatformDispatcher.instance.onError = (error, stack) {
//     if (kReleaseMode && !environment.isDevelopment) {
//       FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     } else {
//       logError('Fatal Error', error: error, stackTrace: stack);
//     }
//     return true;
//   };

//   ErrorWidget.builder = (FlutterErrorDetails details) {
//     return VipFlutterError(details: details);
//   };
// }

// Future<void> _initializeAnalytics(Environment environment) {
//   return FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
//     kReleaseMode && !environment.isDevelopment,
//   );
// }

// Future<void> _initializeBiometric(Ref ref) async {
//   await ref.watch(biometricNotifierProvider.notifier).init();
// }

// Future<void> _initializeLegalTexts(Ref ref) async {
//   ref.read(legalTextNotifierProvider);
// }
