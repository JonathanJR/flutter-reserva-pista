import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/presentation/news/state/news_state.dart';

part 'news_notifier.g.dart';

@riverpod
class NewsNotifier extends _$NewsNotifier {
  @override
  NewsState build() => NewsState.initial();
}
