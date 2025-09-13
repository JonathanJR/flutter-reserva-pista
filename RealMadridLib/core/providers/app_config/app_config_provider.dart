import 'package:flutter/material.dart';
import 'package:rm_app_flutter_cibeles_ui/theme/rm_fan_theme.dart';
import 'package:rm_app_flutter_cibeles_ui/theme/rm_fan_theme_variant.dart';
import 'package:rm_app_flutter_core/core/config/app_config.dart';


import 'package:rm_app_flutter_core/state_management.dart';



part 'app_config_provider.g.dart';

@Riverpod(keepAlive: true)
class AppConfigProvider extends _$AppConfigProvider {
  @override
  AppConfig build() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        
    return AppConfig(
  themeData: RmFanTheme.fromVariant(brightness == Brightness.dark ? RMFanThemeVariant.dark : RMFanThemeVariant.light),
    );
  }

  set config(AppConfig config) {
    state = config;
  }

  AppConfig get config => state;
}


final appConfigProvider = Provider<AppConfig>((ref) {
  return ref.watch(appConfigProviderProvider);
});
