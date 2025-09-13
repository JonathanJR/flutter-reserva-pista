import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_aepcore/flutter_aepcore.dart';
import 'package:rm_app_flutter_core/core/logger/global_logger.dart';
import 'package:rm_app_flutter_core/core/managers/one_trust_manager.dart';

class OneTrustManagerListenerImpl {
  const OneTrustManagerListenerImpl(this._oneTrustManager);

  final OneTrustManager _oneTrustManager;

  void init() {
    _oneTrustManager.listener = _onConsentChanged;
  }

  void dispose() {
    _oneTrustManager.listener = null;
  }

  void _onConsentChanged(PrivacyStatus status) {
    // Convert PrivacyStatus to int for Firebase Analytics
    final intStatus = _privacyStatusToInt(status);
    _setFirebaseConsent(intStatus);
  }

  int _privacyStatusToInt(PrivacyStatus status) {
    return switch (status) {
      PrivacyStatus.opt_in => 1,
      PrivacyStatus.opt_out => 0,
      PrivacyStatus.unknown => -1,
    };
  }

  Future<void> _setFirebaseConsent(int status) async {
    final granted = (status == 1) || false;

    try {
      // TODO: Firebase Analytics consent is not implemented in fan app yet
      logger.d('[OneTrustManager] Firebase consent would be set to: $granted');
    } on PlatformException catch (e) {
      logger.e(
        '[OneTrustManager] setFirebaseConsent($status) failed',
        error: e,
      );
    }
  }
}
