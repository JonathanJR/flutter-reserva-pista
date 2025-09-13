import 'package:dio/dio.dart';
import 'package:rm_app_flutter_core/core/exceptions/server_exceptions.dart';

class AemInterceptor extends Interceptor {
  final String dynamicKey;

  const AemInterceptor(this.dynamicKey);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final modifiedUrl =
        options.uri.toString().replaceAll('&', ';').replaceAll('?', ';');
    options.path = Uri.parse(modifiedUrl).path;
    final optionModified =
        options.copyWith(queryParameters: <String, dynamic>{});
    super.onRequest(optionModified, handler);
  }

  @override
  // ignore: strict_raw_type
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseData = response.data;
    if (responseData is Map && responseData.containsKey('data')) {
      if (responseData['data'] != null) {
        final data = responseData['data'] as Map;
        final wrapper = data[dynamicKey];
        if (wrapper is Map) {
          if (wrapper['item'] != null) {
            response.data = wrapper['item'];
          } else {
            response.data = wrapper;
          }
        }
      } else {
        var errorMessage = 'Data is null';
        final errors = responseData['errors'] as List?;

        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.first as Map?;

          if (firstError != null) {
            if (firstError['message'] != null) {
              errorMessage = firstError['message'] as String;
            }
          }
        }
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: InvalidResponse(
              message: errorMessage,
            ),
          ),
        );
        return;
      }
      handler.next(response);
    } else {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: const InvalidResponse(
            message: 'Invalid response',
          ),
        ),
      );
    }
  }
}
