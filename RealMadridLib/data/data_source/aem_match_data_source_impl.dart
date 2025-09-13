import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_fan/core/providers/dio/dio_config.dart';
import 'package:rm_app_flutter_fan/core/providers/dio/dio_provider.dart';
import 'package:rm_app_flutter_fan/data/api/match/aem_match_api.dart';
import 'package:rm_app_flutter_fan/data/data_source/aem_match_data_source.dart';
import 'package:dio/dio.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_match_list_response.dart';

class AemMatchDataSourceImpl extends RemoteDataStore implements AemMatchDataSource {

  AemMatchDataSourceImpl(super.ref);
    

  @override
  Future<Result<AemMatchListResponse, RMException>> getMatches({
    required String startDate,
    required String endDate,
    required String lang,
   required List<String> squadsIds,
  }) async {

   return ApiUtils.guardedRequest<AemMatchListResponse>(() async {
      final dio = await getDio(
        dioConfig: AemDioConfig(
          keyByPath: 'matchList',
        ),
      );

      return AemMatchApi(dio).getMatches(
        startDate: startDate,
        endDate: endDate,
        lang: lang,
        filterSquad: _createFilterSquad(squadsIds),
      );
    });
      
    
  }


  String _createFilterSquad(List<String> squadsIds) {
    if (squadsIds.isNotEmpty) {
      final squadJson = squadsIds
          .map((id) => '{"_operator":"EQUALS","value":"$id"}')
          .join(',');
      final filterSquadJson =
          '{"optaId":{"_logOp":"OR","_expressions":[$squadJson]}}';
      final encodedFilterSquad = Uri.encodeComponent(filterSquadJson);
      return '%3BfilterSquad=$encodedFilterSquad';
    } else {
      return '';
    }
  }
  
   @override
  Future<Dio> getDio({RMDioConfig? dioConfig}) async {
    if (dioConfig == null) {
      throw Exception('DioConfig is null');
    }

    return ref.watch(
      aemClientProvider(dioConfig as AemDioConfig),
    );
  }
}
