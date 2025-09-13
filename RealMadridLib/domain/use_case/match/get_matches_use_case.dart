import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_fan/domain/i_repositories/match_repository.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';
import 'package:rm_app_flutter_fan/domain/models/match/squad_local.dart';
import 'package:rm_app_flutter_fan/domain/use_case/match/params/get_match_use_case_params.dart';

class GetMatchesUseCase extends UseCaseWithParams<GetMatchUseCaseParams, List<MatchFan>> {
  final MatchRepository repository;

  GetMatchesUseCase(this.repository);
  
  @override
  Future<Result<List<MatchFan>, RMException>> call({
    required GetMatchUseCaseParams params
  }) {
    return repository.getMatches(
      startDate: params.fromDate,
      endDate: params.toDate,
      lang: params.langCode,
      squadsIds:  [SquadLocal.mensFootballFirst()].map((squad) => squad.optaId).toList(),
    );
  }
}
