import 'package:rm_app_flutter_core/navigation.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/presentation/main_navigation/state/main_navigation_state.dart';

part 'main_navigation_bar_notifier.g.dart';

@riverpod
class MainNavigationBarNotifier extends _$MainNavigationBarNotifier {
  late final StatefulNavigationShell _navigationShell;

  @override
  MainNavigationState build(StatefulNavigationShell navigationShell) {
    _navigationShell = navigationShell;
    return MainNavigationState.initial();
  }

  void restart() {
    state = MainNavigationState.initial();
    _navigationShell.goBranch(0);
  }

  void changeIndex(int index) {
    state = state.copyWith(index: index);
    _navigationShell.goBranch(index);
  }
}
