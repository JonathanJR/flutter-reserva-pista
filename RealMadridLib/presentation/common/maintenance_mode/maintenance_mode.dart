import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/core/theme/rm_paddings.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_cibeles_ui/rm_app_flutter_cibeles_ui.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';

enum RMFanMaintenanceModeEnum { general, requireUpdate }

class RMFanMaintenanceMode extends ConsumerWidget {
  const RMFanMaintenanceMode.general({super.key})
    : type = RMFanMaintenanceModeEnum.general;

  const RMFanMaintenanceMode.requireUpdate({super.key})
    : type = RMFanMaintenanceModeEnum.requireUpdate;

  final RMFanMaintenanceModeEnum type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Scaffold(
        backgroundColor: context.colorPalette.primaryBackground,
        // TODO: REMOVE THIS AppBar - Temporary back button for testing purposes only!
        // In production, maintenance mode should NOT have a back button as users
        // should not be able to navigate away from this screen.
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              context.go(RMFanRoutes.home.path);
            },
          ),
          title: Text(
            'TEMPORARY ARROW BACK - REMOVE LATER',
            style: context.textTheme.bodyBoldMedium.copyWith(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: RMPaddings.all24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Padding(
                  padding: RMPaddings.all16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image
                      Padding(
                        padding: RMPaddings.horizontal32,
                        child: Image.asset(
                          switch (type) {
                            RMFanMaintenanceModeEnum.general =>
                              'assets/images/img_maintenance.png',
                            RMFanMaintenanceModeEnum.requireUpdate =>
                              'assets/images/img_update.png',
                          },
                          width: 264,
                          height: 206,
                          fit: BoxFit.contain,
                        ),
                      ),
                      RMSpacing.gap16,

                      // Title
                      Text(
                        textAlign: TextAlign.center,
                        switch (type) {
                          RMFanMaintenanceModeEnum.general =>
                            'maintenanceModeTitle'.rtr,
                          RMFanMaintenanceModeEnum.requireUpdate =>
                            'maintenanceUpdateModeTitle'.rtr,
                        },
                        style: context.textTheme.headingH4SmallBold.copyWith(
                          color: context.colorPalette.grayscaleTitle,
                        ),
                      ),
                      RMSpacing.gap16,

                      // Description
                      Text(
                        switch (type) {
                          RMFanMaintenanceModeEnum.general =>
                            'maintenanceModeDescription'.rtr,
                          RMFanMaintenanceModeEnum.requireUpdate =>
                            'maintenanceUpdateModeDescription'.rtr,
                        },
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyTextMedium.copyWith(
                          color: context.colorPalette.grayscaleBody,
                        ),
                      ),
                      RMSpacing.gap24,
                    ],
                  ),
                ),
              ),

              // Update Button (only for requireUpdate type)
              if (type == RMFanMaintenanceModeEnum.requireUpdate)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _handleUpdateButtonPressed();
                    },
                    child: Text('commonUpdate'.rtr),
                  ),
                ),
              RMSpacing.gap48,
            ],
          ),
        ),
      ),
    );
  }

  void _handleUpdateButtonPressed() {
    // Handle update button press - redirect to store
    // TODO: Implement store redirect functionality
    print('Update button pressed');
  }
}
