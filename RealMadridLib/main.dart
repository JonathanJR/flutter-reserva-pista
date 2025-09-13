import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:rm_app_flutter_core/application/startup/rm_startup_app.dart';
import 'package:rm_app_flutter_core/core/config/easy_localization_config.dart';
import 'package:rm_app_flutter_core/core/config/remote_configuration_config.dart';
import 'package:rm_app_flutter_core/core/config/rm_config.dart';
import 'package:rm_app_flutter_core/data/models/remote_config_model.dart';
import 'package:rm_app_flutter_core/rm_core_initialization.dart';
import 'package:rm_app_flutter_fan/application/remote_config/fan_remote_config.dart';
import 'package:rm_app_flutter_fan/application/remote_config/remote_config_service.dart';
import 'package:rm_app_flutter_fan/core/constants/env.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_router.dart';
import 'package:rm_app_flutter_fan/core/providers/app_config/app_config_provider.dart';
import 'package:rm_app_flutter_fan/core/providers/remote_config/remote_config_providers.dart';
import 'package:rm_app_flutter_fan/core/providers/startup/app_startup_provider.dart';

void main() => runRMApp();

const supportedLocales = [
  Locale('es', 'ES'),
  Locale('en', 'US'),
];

Future<void> runRMApp() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await RMCoreInitialization.initialize(
    rmConfig: RMConfig(
      indigitallConfig: Env.indigitall.toIndigitallConfig(),
      oneTrustConfig: Env.oneTrust.toOneTrustConfig(
        supportedLocales: supportedLocales,
        platformLanguageCode: Platform.localeName,
      ),
      internetConfig: null,
      
      // InternetConfig(
      //   onConnected: (context) => ToastUtils.showConnectionActive(
      //     context,
      //     'commonConnectionSuccess'.rtr,
      //   ),
      //   onDisconnected: (context) => ToastUtils.showErrorToast(
      //     context,
      //     'commonConnectionError'.rtr,
      //   ),
      // ),
      // toastProviderConfig: ToastProviderConfig(
      //   onToast: (context, toastConfig, ref) => ToastUtils.showToast(
      //     context,
      //     toastConfig.message,
      //     title: toastConfig.title,
      //     ref: ref,
      //     type: toastConfig.type,
      //   ),
      // ),
      remoteConfigurationConfig: RemoteConfigurationConfig<RemoteConfigModel>(
        dataSourceProvider: remoteConfigDataSourceProvider,
        onFetchedRemoteConfig: (config) {
          final fanConfig = config as FanRemoteConfig;
          RemoteConfigService.setConfig(fanConfig);
        },
      ),
      adobeConfig: Env.aem.toAdobeConfig(),
      appStartupProvider: appStartupProvider,
      environment: Env.environment,
      routerProvider: routerProvider,
      appConfigProvider: appConfigProvider,
      easyLocalizationConfig: const EasyLocalizationConfig(
        supportedLocales: supportedLocales,
        path: 'assets/i18n',
        fallbackLocale: Locale('es', 'ES'),
      ),
    ),
  );
  //TODO (init): 
  hideSplashScreen();

  runApp(const RMStartupApp());
}


Future<void> hideSplashScreen({Duration duration = Duration.zero}) {
  return Future.delayed(
    duration,
    FlutterNativeSplash.remove,
  );
}