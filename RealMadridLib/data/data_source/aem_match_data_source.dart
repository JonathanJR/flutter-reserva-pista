import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_match_list_response.dart';

abstract class AemMatchDataSource {
 

  Future<Result<AemMatchListResponse, RMException>> getMatches({
    required String startDate,
    required String endDate,
    required String lang,
   required List<String> squadsIds,
  });
}
