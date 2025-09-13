import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:rm_app_flutter_core/data/data.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/core/constants/env.dart';
import 'package:rm_app_flutter_fan/core/interceptor/aem_interceptor.dart';
import 'package:rm_app_flutter_fan/core/providers/dio/dio_config.dart';

final narmClientProvider = Provider.family<Dio, DioConfig>(
  (ref, dioConfig) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Env.narm.baseUrl}${dioConfig.microServiceName}',
        contentType: 'application/json',
      ),
    );

    dio.interceptors.addAll(
      [
        if (dioConfig.cacheOptions != null)
          DioCacheInterceptor(options: dioConfig.cacheOptions!),
        // AuthorizationInterceptor(
        //   ref.read(authNotifierProvider.notifier),
        // ),
        RMErrorInterceptor(),
      //  DioFirebasePerformanceInterceptor(),
        if (kDebugMode && Env.debug.debugPrettyDioLogger) PrettyDioLogger(),
        if (kDebugMode && Env.debug.debugCurlLogger)
          CurlLoggerDioInterceptor(printOnSuccess: true),
      ],
    );

    return dio;
  },
  name: 'narmClientProvider',
);



final dioDecoderProvider = Provider.autoDispose<Dio>(
  (ref) => Dio(
    BaseOptions(
      baseUrl: Env.aem.baseUrl,
      responseDecoder: (responseBytes, options, responseBody) {
        if (options.headers['content-type'] ==
            'application/graphql-response+json;charset=iso-8859-1') {
          if (options.headers['content-encoding'] == 'gzip') {
            final decoded = gzip.decode(responseBytes);
            return String.fromCharCodes(decoded);
          }
          return String.fromCharCodes(responseBytes);
        }
        return utf8.decode(responseBytes);
      },
    ),
  ),
  name: 'dioDecoderProvider',
);

final aemClientProvider = Provider.family<Dio, AemDioConfig>(
  (ref, aemConfig) {
    final dio = ref.read(dioDecoderProvider);

    dio.interceptors.addAll(
      [
        if (aemConfig.cacheOptions != null)
          DioCacheInterceptor(options: aemConfig.cacheOptions!),
        if (kDebugMode && Env.debug.debugCurlLogger)
          CurlLoggerDioInterceptor(printOnSuccess: true),
        RMErrorInterceptor(),
        AemInterceptor(aemConfig.keyByPath),
       // DioFirebasePerformanceInterceptor(),
        if (kDebugMode && Env.debug.debugPrettyDioLogger) PrettyDioLogger(),
      ],
    );

    return dio;
  },
  name: 'aemClient',
);
