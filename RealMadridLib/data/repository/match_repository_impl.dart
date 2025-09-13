import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_fan/data/data_source/aem_match_data_source.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_match.dart';
import 'package:rm_app_flutter_fan/domain/i_repositories/match_repository.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';

class MatchRepositoryImpl implements MatchRepository {
  List<MatchFan> _mapToMatchFan(List<AemMatch>? items) {
    if (items == null) return [];
    return items.map((item) => MatchFan(
      id: item.id ?? '',
      homeTeam: item.homeTeam?.name ?? '',
      awayTeam: item.awayTeam?.name ?? '',
      date: item.dateTime ?? DateTime.now(),
     // date: item.date != null ? DateTime.parse(item.date!) : DateTime.now(),
      stadium: item.venue?.name ?? '',
      competition: item.competition?.name ?? '',
    )).toList();
  }
  final AemMatchDataSource dataSource;

  MatchRepositoryImpl(this.dataSource);

  @override
  Future<Result<List<MatchFan>, RMException>> getMatches({
    required DateTime startDate,
    required DateTime endDate,
    required String lang,
    required List<String> squadsIds,
  }) async {
    final result = await dataSource.getMatches(
      startDate: startDate.toIso8601String(),
      endDate: endDate.toIso8601String(),
      lang: lang,
      squadsIds: squadsIds,
    );

    return result.map(
      successMapper: (data) => _mapToMatchFan(data.items),
      errorMapper: (error) => error,
    );
  }
}
