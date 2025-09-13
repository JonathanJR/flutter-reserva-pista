import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/core/theme/rm_paddings.dart';
import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold.dart';
import 'package:rm_app_flutter_core/presentation/common/widgets/scaffold/rm_scaffold_body.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/navigation/rm_fan_routes.dart';
import 'package:rm_app_flutter_fan/presentation/main_navigation/notifier/main_navigation_bar_notifier.dart';

class MainNavigationScaffold extends StatelessWidget {
  const MainNavigationScaffold({
    required this.navigationShell,
    this.route,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('MainNavigationScaffold'));

  final StatefulNavigationShell navigationShell;
  final RMFanRoutes? route;

  @override
  Widget build(BuildContext context) {
    return RMScaffold(
      extendBody: true,
      key: ValueKey(route?.name),
      backgroundColor: Colors.transparent,
      bottomBar:
          (route?.isPrimary() ?? false) ? _BottomBar(navigationShell) : null,
      bodyBuilder: (_) => RMBody(child: navigationShell),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _BottomBar(this.navigationShell);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: MediaQuery.of(context).viewPadding,
     // clipBehavior: Clip.antiAlias,
      // decoration: BoxDecoration(
      //   color: Colors.blue,
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(RMSpacing.s32),
      //     topRight: Radius.circular(RMSpacing.s32),
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.green,// context.colorPalette.level2,
      //       blurRadius: 44,
      //       offset: const Offset(0, -14),
      //       spreadRadius: -14,
      //     ),
      //   ],
      // ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomIcon(
            // selectedIcon: Assets.icons.navigation.home,
            // unselectedIcon: Assets.icons.navigation.light.home,
            text: 'mainNavHome'.rtr,
            index: 0,
            navigationShell: navigationShell,
          ),
          _BottomIcon(
            // selectedIcon: Assets.icons.navigation.wallet,
            // unselectedIcon: Assets.icons.navigation.light.wallet,
            text: 'mainNavNews'.rtr,
            index: 1,
            navigationShell: navigationShell,
          ),
          _BottomIcon(
            // selectedIcon: Assets.icons.navigation.assistant,
            // unselectedIcon: Assets.icons.navigation.light.assistant,
            text: 'mainNavCalendar'.rtr,
            index: 2,
            navigationShell: navigationShell,
          ),

          _BottomIcon(
            // selectedIcon: Assets.icons.navigation.assistant,
            // unselectedIcon: Assets.icons.navigation.light.assistant,
            text: 'mainNavRMTV'.rtr,
            index: 3,
            navigationShell: navigationShell,
          ),

          _BottomIcon(
            // selectedIcon: Assets.icons.navigation.assistant,
            // unselectedIcon: Assets.icons.navigation.light.assistant,
            text: 'mainNavShop'.rtr,
            index: 4,
            navigationShell: navigationShell,
          ),
        ],
      ),
    );
  }
}

class _BottomIcon extends ConsumerWidget {
  // final SvgGenImage selectedIcon;
  // final SvgGenImage unselectedIcon;
  final String text;
  final int index;
  final StatefulNavigationShell navigationShell;

  const _BottomIcon({
    // required this.selectedIcon,
    // required this.unselectedIcon,
    required this.text,
    required this.index,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref
            .read(
              mainNavigationBarNotifierProvider(navigationShell).notifier,
            )
            .changeIndex(index),
        child: ColoredBox(
          // This color is necessary for expanded buttons,
          // ensuring that clicks near the button
          // still trigger the desired action
          color: Colors.white,
          child: Padding(
            padding: RMPaddings.vertical12,

            child: Text(text)
            // child: Column(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     ((navigationShell.currentIndex == index)
            //             ? selectedIcon
            //             : unselectedIcon)
            //         .svg(
            //       width: RMSpacing.s24,
            //       height: RMSpacing.s24,
            //       colorFilter: navigationShell.currentIndex == index
            //           ? null
            //           : ColorFilter.mode(
            //               context.colorPalette.contentNeutralQuaternary,
            //               BlendMode.srcIn,
            //             ),
            //     ),
            //     RMSpacing.gap4,
            //     if (navigationShell.currentIndex == index)
            //         Text(
            //         text,
            //         style:  context.textTheme.labelMSemibold,)
             
            //     else
            //       Text(
            //         text,
            //         style: context.textTheme.labelMSemibold.copyWith(
            //           color: context.colorPalette.contentNeutralQuaternary,
            //         ),
            //       ),
            //   ],
            // ),
          ),
        ),
      ),
    );
  }
}
