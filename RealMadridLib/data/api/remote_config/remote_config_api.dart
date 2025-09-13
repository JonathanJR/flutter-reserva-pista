import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:rm_app_flutter_fan/application/remote_config/fan_remote_config.dart';

part 'remote_config_api.g.dart';

@RestApi()
abstract class RemoteConfigApi {
  factory RemoteConfigApi(Dio dio, {String? baseUrl}) = _RemoteConfigApi;

  @GET('/content/dam/common/statics/public-content/internet/app/rm-app-flutter-fan/features-configuration.json')
  Future<FanRemoteConfig> getFile();
}
