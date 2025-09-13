import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_fan/application/remote_config/remote_config_service.dart';
import 'package:rm_app_flutter_fan/core/utils/app_utils.dart';

typedef GoRouterRedirect =
    FutureOr<String?> Function(BuildContext context, GoRouterState state);

/// Implements a guard to handle route access logic based on maintenance mode
/// and update requirements for the RM Fan App.
class RMFanRouterGuard {
  /// Routes that are accessible during maintenance mode.
  final List<String> allowedWithoutChecks;

  /// Redirect function for maintenance mode.
  final GoRouterRedirect maintenanceRedirect;

  /// Redirect function for update required state.
  final GoRouterRedirect updateRequiredRedirect;

  RMFanRouterGuard({
    required this.allowedWithoutChecks,
    required this.maintenanceRedirect,
    required this.updateRequiredRedirect,
  });

  /// Handles the logic for determining route access and redirection.
  FutureOr<String?> guard(BuildContext context, GoRouterState state) async {
    final currentLocation = state.matchedLocation;

    // Check if the route is allowed without any checks (maintenance routes)
    if (allowedWithoutChecks.contains(currentLocation)) {
      return null;
    }

    if (RemoteConfigService.isMaintenanceMode) {
      return _safeReturn(maintenanceRedirect(context, state));
    } else if (RMFanAppUtils.isUpdateRequired(
      RemoteConfigService.minimumAppVersion,
    )) {
      return _safeReturn(updateRequiredRedirect(context, state));
    }

    return _safeReturn(null);
  }

  FutureOr<String?> _safeReturn(FutureOr<String?> result) async {
    return result;
  }
}

/// Applies each guard's logic sequentially and stops at the first
/// non-null result.
extension MultiLogicGoRouterGuardList on List<RMFanRouterGuard> {
  FutureOr<String?> guard(BuildContext context, GoRouterState state) async {
    for (final guard in this) {
      final result = await guard.guard(context, state);
      if (result != null) return result; // Stop at the first valid redirect.
    }
    return null; // Allow access if no guard produces a redirect.
  }
}
