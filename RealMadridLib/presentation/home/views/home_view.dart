import 'package:flutter/material.dart';
import 'package:rm_app_flutter_cibeles_ui/rm_app_flutter_cibeles_ui.dart';
import 'package:rm_app_flutter_core/core/theme/rm_paddings.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold_body.dart';
import 'package:rm_app_flutter_fan/domain/providers/analytics/analytics_providers.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/home/notifier/home_notifier.dart';
import 'package:rm_app_flutter_fan/presentation/match/views/next_match_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userIsLoaded = ref.read(homeNotifierProvider).isUserLogged;
    final matches = ref.watch(homeNotifierProvider).matches;

    ref.listen(analyticsRepositoryProvider, (previous, next) {
      // This will be called when the provider is first accessed
      if (previous == null) {
        next.trackScreenView(screenName: 'home_page');
      }
    });
    ref.read(analyticsRepositoryProvider);

    return RMScaffold(
      backgroundColor: context.colorPalette.primaryBackground,
      appBar: null,
      bodyBuilder: (_) => RMBody(
        bodyPadding: RMPaddings.horizontal24,
        topSafe: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('home $userIsLoaded', style: context.textTheme.bodyBoldMedium),
            const SizedBox(height: 24),
            NextMatchWidget(matches: matches),
            const SizedBox(height: 24),

            // Dummy buttons for testing maintenance screens
            Text(
              'Maintenance Mode Testing:',
              style: context.textTheme.bodyBoldMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(RMFanRoutes.maintenance.path);
                    },
                    child: const Text('Show Maintenance'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(RMFanRoutes.updateRequired.path);
                    },
                    child: const Text('Show Update Required'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}