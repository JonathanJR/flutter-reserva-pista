import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/data/data_source/aem_match_data_source.dart';
import 'package:rm_app_flutter_fan/data/data_source/aem_match_data_source_impl.dart';
import 'package:rm_app_flutter_fan/data/repository/match_repository_impl.dart';
import 'package:rm_app_flutter_fan/domain/i_repositories/match_repository.dart';
import 'package:rm_app_flutter_fan/domain/use_case/match/get_matches_use_case.dart';

part 'match_providers.g.dart';

@riverpod
AemMatchDataSource aemMatchDataSource(Ref ref) {
  return AemMatchDataSourceImpl(ref);
}

@riverpod
MatchRepository matchRepository(Ref ref) {
  final aemDataSource = ref.read(aemMatchDataSourceProvider);
  return MatchRepositoryImpl(aemDataSource);
}

@riverpod
GetMatchesUseCase getMatchesUseCase(Ref ref) {
  final repository = ref.read(matchRepositoryProvider);
  return GetMatchesUseCase(repository);
}
