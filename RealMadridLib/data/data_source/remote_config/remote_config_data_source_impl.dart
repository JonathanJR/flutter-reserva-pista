import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/core/logger/global_logger.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_core/data/data_source/iremote_config_data_source.dart';
import 'package:rm_app_flutter_fan/application/remote_config/fan_remote_config.dart';
import 'package:rm_app_flutter_fan/core/constants/env.dart';
import 'package:rm_app_flutter_fan/data/api/remote_config/remote_config_api.dart';

class RemoteConfigDataSourceImpl extends RemoteDataStore
    implements IRemoteConfigDataSource<FanRemoteConfig> {
  RemoteConfigDataSourceImpl(super.ref);

  @override
  Future<void> clearCache() async {
    logInfo('Clearing remote config cache');
    try {
      final file = File(await getFileName());
      if (file.existsSync()) {
        await file.delete();
        logInfo('Remote config cache cleared successfully');
      }
    } catch (e) {
      logError('Error clearing remote config cache: $e');
    }
  }

  @override
  Future<Result<FanRemoteConfig, RMException>> fetchRemoteConfig() async {
    final dio = await getDio();

    final result = await ApiUtils.guardedRequest<FanRemoteConfig>(
      () async {
        final file = await RemoteConfigApi(dio).getFile();
        unawaited(saveConfigFile(jsonEncode(file.toJson())));

        return file;
      },
    );

    if (result.isError()) {
      logError('Error fetching remote config: ${result.tryGetError()}');

      // Try to read from local cache first
      final localConfig = await readConfigFile();
      if (localConfig != null && localConfig.isNotEmpty) {
        try {
          return Success(
            FanRemoteConfig.fromJson(
              jsonDecode(localConfig) as Map<String, dynamic>,
            ),
          );
        } catch (e) {
          logError('Error parsing LOCAL config: $e');
        }
      }

      // If local cache fails, try to read from assets
      try {
        final assetConfig = await readAssetConfigFile();
        if (assetConfig != null && assetConfig.isNotEmpty) {
          return Success(
            FanRemoteConfig.fromJson(
              jsonDecode(assetConfig) as Map<String, dynamic>,
            ),
          );
        }
      } catch (e) {
        logError('Error parsing ASSET config: $e');
      }

      return Error(GeneralException.fromObject('No config found'));
    }

    return result;
  }

  @override
  Future<Dio> getDio({RMDioConfig? dioConfig}) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.aem.baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseDecoder: (responseBytes, options, responseBody) {
          if (options.headers['content-encoding'] == 'gzip') {
            final decoded = gzip.decode(responseBytes);
            return utf8.decode(decoded);
          }
          return utf8.decode(responseBytes);
        },
      ),
    );

    if (kDebugMode && Env.debug.debugCurlLogger) {
      dio.interceptors.addAll([CurlLoggerDioInterceptor(printOnSuccess: true)]);
    }
    
    // Add error handling interceptor
    dio.interceptors.add(RMErrorInterceptor());
    
    return dio;
  }

  Future<void> saveConfigFile(String content) async {
    try {
      final file = File(await getFileName());
      await file.writeAsString(content);
      logInfo('Remote config saved to local cache');
    } catch (e) {
      logError('Error saving config file: $e');
    }
  }

  Future<String?> readConfigFile() async {
    try {
      final file = File(await getFileName());
      if (file.existsSync()) {
        return await file.readAsString();
      }
    } catch (e) {
      logError('Error reading config file: $e');
    }
    return null;
  }

  Future<String?> readAssetConfigFile() async {
    try {
      logInfo('Reading remote config from assets fallback');
      return await rootBundle.loadString('assets/files/remote_config.json');
    } catch (e) {
      logError('Error reading asset config file: $e');
      return null;
    }
  }

  Future<String> getFileName() async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/fan_config.json';
  }
}
