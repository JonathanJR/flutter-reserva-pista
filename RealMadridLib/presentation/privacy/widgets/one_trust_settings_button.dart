import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/application/startup/providers/providers.dart';
import 'package:rm_app_flutter_core/state_management.dart';

class OneTrustSettingsButton extends ConsumerWidget {
  final String? title;
  final IconData? icon;
  final bool showAsCard;

  const OneTrustSettingsButton({
    super.key,
    this.title,
    this.icon,
    this.showAsCard = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> onPressed() async {
      final oneTrustManager = ref.read(oneTrustProvider);
      
      // First try to show banner if user hasn't seen it
      final shouldShowBanner = await oneTrustManager.hasSeenConsentScreen();
      
      if (!shouldShowBanner) {
        // Show initial consent banner
        await oneTrustManager.showBannerUIIfNeeded();
      } else {
        // Show preference center for managing existing settings
        await oneTrustManager.showPreferenceCenter();
      }
    }

    if (showAsCard) {
      return Card(
        child: ListTile(
          leading: Icon(icon ?? Icons.privacy_tip_outlined),
          title: Text(title ?? 'Privacy Settings'),
          subtitle: const Text('Manage your data and privacy preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onPressed,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.privacy_tip_outlined),
      label: Text(title ?? 'Privacy Settings'),
    );
  }
}
