import 'dart:io';
import 'dart:ui';

import 'package:flutter_aepcore/flutter_aepcore.dart';
import 'package:flutter_aepedge/flutter_aepedge.dart';
import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/core/managers/one_trust_manager.dart';
import 'package:rm_app_flutter_core/utils/analytic_categories.dart';

class AdobeAnalyticRepositoryImpl {
  final Locale language;
  final OneTrustManager _oneTrustManager;

  AdobeAnalyticRepositoryImpl(this.language, this._oneTrustManager);

  Future<String> getGDPRStatus() async {
    final status = await MobileCore.privacyStatus;
    return switch (status) {
      PrivacyStatus.opt_in => '1',
      PrivacyStatus.opt_out => '0',
      PrivacyStatus.unknown => 'not_set'
    };
  }

  Future<void> trackScreenView({required String screenName}) async {
    final hasSeenConsentScreen = await _oneTrustManager.hasSeenConsentScreen();
    final consentNotSet = hasSeenConsentScreen ? null : 'not_set';

    final strictlyConsent = consentNotSet ??
        (await _oneTrustManager
                .getConsentForCategory(AnalyticsCategories.strictly))
            .asStatus();
    
    final performanceConsent = consentNotSet ??
        (await _oneTrustManager
                .getConsentForCategory(AnalyticsCategories.performance))
            .asStatus();

    final trackingData = <String, dynamic>{
      'screen_name': screenName,
      'consent_strictly': strictlyConsent,
      'consent_performance': performanceConsent,
      'gdpr_status': await getGDPRStatus(),
      'language': language.languageCode,
      'platform': Platform.isIOS ? 'iOS' : 'android',
    };

    try {
      final experienceEvent = ExperienceEvent({
        'xdm': {
          'eventType': 'screen_view',
          'data': trackingData,
        }
      });
      await Edge.sendEvent(experienceEvent);
      
      logger.d('[Analytics] Screen view tracked: $screenName');
    } catch (e) {
      logger.e('[Analytics] Failed to track screen view', error: e);
    }
  }

  /// Example method to track a custom event with OneTrust consent status
  Future<void> trackEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    final hasSeenConsentScreen = await _oneTrustManager.hasSeenConsentScreen();
    final consentNotSet = hasSeenConsentScreen ? null : 'not_set';

    // Get consent status for different categories
    final consents = {
      'strictly': consentNotSet ??
          (await _oneTrustManager
                  .getConsentForCategory(AnalyticsCategories.strictly))
              .asStatus(),
      'performance': consentNotSet ??
          (await _oneTrustManager
                  .getConsentForCategory(AnalyticsCategories.performance))
              .asStatus(),
      'functional': consentNotSet ??
          (await _oneTrustManager
                  .getConsentForCategory(AnalyticsCategories.functional))
              .asStatus(),
      'targeting': consentNotSet ??
          (await _oneTrustManager
                  .getConsentForCategory(AnalyticsCategories.targeting))
              .asStatus(),
    };

    // Create tracking data with consent information
    final trackingData = <String, dynamic>{
      'event_name': eventName,
      'consents': consents,
      'gdpr_status': await getGDPRStatus(),
      'language': language.languageCode,
      'platform': Platform.isIOS ? 'iOS' : 'android',
      ...?parameters,
    };

    // Send to Adobe Analytics
    try {
      final experienceEvent = ExperienceEvent({
        'xdm': {
          'eventType': 'custom_event',
          'data': trackingData,
        }
      });
      await Edge.sendEvent(experienceEvent);
      
      logger.d('[Analytics] Event tracked: $eventName');
    } catch (e) {
      logger.e('[Analytics] Failed to track event', error: e);
    }
  }
}
