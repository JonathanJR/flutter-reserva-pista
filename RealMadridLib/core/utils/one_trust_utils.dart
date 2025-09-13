import 'package:rm_app_flutter_core/core/managers/one_trust_manager.dart';
import 'package:rm_app_flutter_core/utils/analytic_categories.dart';

class OneTrustUtils {
  static Future<Map<String, String>> getAllConsentStatuses(
    OneTrustManager oneTrustManager,
  ) async {
    final results = <String, String>{};

    final categories = [
      AnalyticsCategories.strictly,
      AnalyticsCategories.performance,
      AnalyticsCategories.functional,
      AnalyticsCategories.targeting,
      AnalyticsCategories.social,
      AnalyticsCategories.personalization,
      AnalyticsCategories.sharing,
    ];
    
    for (final category in categories) {
      try {
        final consent = await oneTrustManager.getConsentForCategory(category);
        results[category] = consent.asStatus();
      } catch (e) {
        results[category] = 'not_set';
      }
    }
    
    return results;
  }

  static Future<bool> isAnalyticsAllowed(OneTrustManager oneTrustManager) async {
    try {
      final strictlyConsent = await oneTrustManager
          .getConsentForCategory(AnalyticsCategories.strictly);
      final performanceConsent = await oneTrustManager
          .getConsentForCategory(AnalyticsCategories.performance);
      
      // Analytics is allowed if both strictly and performance consents are granted
      return strictlyConsent.status == 1 && performanceConsent.status == 1;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isPersonalizationAllowed(
    OneTrustManager oneTrustManager,
  ) async {
    try {
      final personalizationConsent = await oneTrustManager
          .getConsentForCategory(AnalyticsCategories.personalization);
      final targetingConsent = await oneTrustManager
          .getConsentForCategory(AnalyticsCategories.targeting);

      return personalizationConsent.status == 1 && targetingConsent.status == 1;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getConsentSummary(
    OneTrustManager oneTrustManager,
  ) async {
    final hasSeenConsent = await oneTrustManager.hasSeenConsentScreen();
    final analyticsAllowed = await isAnalyticsAllowed(oneTrustManager);
    final personalizationAllowed = await isPersonalizationAllowed(oneTrustManager);
    final allStatuses = await getAllConsentStatuses(oneTrustManager);
    
    return {
      'has_seen_consent_screen': hasSeenConsent,
      'analytics_allowed': analyticsAllowed,
      'personalization_allowed': personalizationAllowed,
      'privacy_status': oneTrustManager.privacyStatus.name,
      'individual_consents': allStatuses,
    };
  }
}
