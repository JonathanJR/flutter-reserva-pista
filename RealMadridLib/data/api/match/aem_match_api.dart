import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import 'package:rm_app_flutter_core/data/data.dart';

import 'package:rm_app_flutter_fan/data/models/match/aem_match_list_response.dart';


part 'aem_match_api.g.dart';

@RestApi()
abstract class AemMatchApi {
  factory AemMatchApi(Dio dio, {String baseUrl}) = _AemMatchApi;

  @GET(
    'graphql/execute.json/realmadridmastersite/diary%3BfromDate={startDate}%3BtoDate={endDate}%3Balang={lang}{filterSquad}',
  )
  Future<AemMatchListResponse> getMatches({
    @Path('startDate') required String startDate,
    @Path('endDate') required String endDate,
    @Path('lang') required String lang,
    @Path('filterSquad') required String filterSquad,
  });
}
