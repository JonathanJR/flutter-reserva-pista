import 'package:rm_app_flutter_core/core/core.dart';

enum LogoutReason {
  userRequested,
  unauthorized,
  invalidInitialization,
  trustedNoDelegate;

  String get label {
    switch (this) {
      case LogoutReason.userRequested:
        return '';
      case LogoutReason.unauthorized:
        return 'commonErrorSessionExpired'.rtr;
      case LogoutReason.trustedNoDelegate:
        return 'loginErrorTrustedNoDelegate'.rtr;
      case LogoutReason.invalidInitialization:
        return 'commonErrorBack'.rtr;
    }
  }
}
