import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_core/data/data_source/iremote_config_data_source.dart';
import 'package:rm_app_flutter_fan/application/remote_config/fan_remote_config.dart';
import 'package:rm_app_flutter_fan/data/data_source/remote_config/remote_config_data_source_impl.dart';

part 'remote_config_providers.g.dart';

@Riverpod(keepAlive: true)
IRemoteConfigDataSource<FanRemoteConfig> remoteConfigDataSource(Ref ref) {
  return RemoteConfigDataSourceImpl(ref);
}
