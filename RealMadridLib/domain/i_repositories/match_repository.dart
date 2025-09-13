import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';

abstract class MatchRepository {
  Future<Result<List<MatchFan>, RMException>> getMatches({
    required DateTime startDate,
    required DateTime endDate,
    required String lang,
    required List<String> squadsIds,
  });
}
