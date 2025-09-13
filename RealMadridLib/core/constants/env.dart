import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:rm_app_flutter_core/core/config/adobe_config.dart';
import 'package:rm_app_flutter_core/core/config/indigitall_config.dart';
import 'package:rm_app_flutter_core/core/config/one_trust_config.dart';
import 'package:rm_app_flutter_core/core/enums/environment.dart';

class Env {
  static Environment get environment => Environment.values.firstWhere(
        (e) => e.name == appFlavor,
        orElse: () => Environment.development,
      );
  static IndigitallConstants get indigitall => IndigitallConstants();
  static OneTrustConstants get oneTrust => OneTrustConstants();
  static AemConstants get aem => AemConstants();
  static NarmConstants get narm => NarmConstants();
  static DebugConfig get debug => DebugConfig();

}

class NarmConstants {
  final baseUrl = const String.fromEnvironment('NARM_BASE_URL');
  final clientId = const String.fromEnvironment('NARM_CLIENT_ID');
  final clientSecret = const String.fromEnvironment('NARM_CLIENT_SECRET');
  final apiSubscriptionKey =
      const String.fromEnvironment('NARM_API_SUBSCRIPTION_KEY');
}

class IndigitallConstants {
  String appKey = const String.fromEnvironment('INDIGITALL_APP_KEY');
  String senderId = const String.fromEnvironment('INDIGITALL_SENDER_ID');
  String url = const String.fromEnvironment('INDIGITALL_URL');

  IndigitallConfig toIndigitallConfig() {
    return IndigitallConfig(
      appKey: appKey,
      senderId: senderId,
      url: url,
      autoRequest: false,
    );
  }
}

class OneTrustConstants {
  final cdn = const String.fromEnvironment('ONE_TRUST_CDN');
  final androidId = const String.fromEnvironment('ONE_TRUST_ANDROID_ID');
  final iosId = const String.fromEnvironment('ONE_TRUST_IOS_ID');

  OneTrustConfig toOneTrustConfig({
    required List<Locale> supportedLocales,
    required String platformLanguageCode,
  }) {
    final languageCode = supportedLocales
        .firstWhere(
          (locale) => locale.languageCode == platformLanguageCode,
          orElse: () => supportedLocales.first,
        )
        .languageCode;

    return OneTrustConfig(
      oneTrustCDN: cdn,
      oneTrustIdAndroid: androidId,
      oneTrustIdiOS: iosId,
      languageCode: languageCode,
    );
  }
}

class AemConstants {
  String aemId = const String.fromEnvironment('ADOBE_ID');
  String consentDatasetId =
      const String.fromEnvironment('ADOBE_CONSENT_DATASET_ID');
  String noConsentDatasetId =
      const String.fromEnvironment('ADOBE_NO_CONSENT_DATASET_ID');
  String baseUrl = const String.fromEnvironment('URL_ADOBE');
  
  AdobeConfig toAdobeConfig() {
    return AdobeConfig(
      adobeId: aemId,
    );
  }
}

class DebugConfig {
  bool debugPrettyDioLogger =
      const bool.fromEnvironment('PRETTY_DIO_LOGGER', defaultValue: true);

  bool debugCurlLogger = const bool.fromEnvironment(
    'CURL_LOGGER_DIO_INTERCEPTOR',
    defaultValue: true,
  );

  String userEmail = const String.fromEnvironment(
    'DEV_MODE_USER_EMAIL',
  );
  String userPassword = const String.fromEnvironment(
    'DEV_MODE_USER_PASSWORD',
  );
}
