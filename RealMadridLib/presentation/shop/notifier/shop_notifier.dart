import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/presentation/shop/state/shop_state.dart';

part 'shop_notifier.g.dart';

@riverpod
class ShopNotifier extends _$ShopNotifier {
  @override
  ShopState build() => ShopState.initial();
}
