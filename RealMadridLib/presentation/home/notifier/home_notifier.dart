
import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/core/extensions/date_time_ext.dart';
import 'package:rm_app_flutter_core/data/use_case/use_case_utils.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';
import 'package:rm_app_flutter_fan/domain/providers/match/match_providers.dart';
import 'package:rm_app_flutter_fan/domain/use_case/match/get_matches_use_case.dart';
import 'package:rm_app_flutter_fan/domain/use_case/match/params/get_match_use_case_params.dart';
import 'package:rm_app_flutter_fan/presentation/home/state/home_state.dart';

part 'home_notifier.g.dart';

@riverpod
class HomeNotifier extends _$HomeNotifier {

  @override
  HomeState build() {

    Future(_loadMatches);
    return HomeState.initial();

  }

  Future<void> _loadMatches() async {
    executeUseCaseWithParams< List<MatchFan>, RMException, GetMatchUseCaseParams,
        GetMatchesUseCase>(
      useCase: () async => await ref.read(getMatchesUseCaseProvider),
      params: GetMatchUseCaseParams(
        langCode: 'es-es',
        fromDate: DateTime.now().subtractMonths(3),
        toDate: DateTime.now().addMonths(3),
      ),
      valueState: () => state.matches,
      onUpdateState: (newState) {
         state = state.copyWith(
          matches: newState,
          );
      },
    );
  }

}