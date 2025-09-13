import 'package:rm_app_flutter_core/core/exceptions/rm_exception.dart';
import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemResponseWrapper<T> {
  final AemByPathWrapper<T>? data;
  final List<GeneralException>? errors;

  AemResponseWrapper({required this.data, this.errors});

  factory AemResponseWrapper.fromJson(
    String keyByPath,
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final jsonData = json['data'] as Map<String, dynamic>?;
    if (jsonData == null) {
      throw Exception('Data [AdobeResponseWrapper] in response is null');
    }

    return AemResponseWrapper(
      data: AemByPathWrapper.fromJson(
        jsonData[keyByPath] as Map<String, dynamic>,
        fromJsonT,
      ),
      errors: json.getMappedListOrNull(
        'errors',
        GeneralException.fromJson,
      ),
    );
  }

  factory AemResponseWrapper.fromJsonList(
    String keyByPath,
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final jsonData = json['data'] as Map<String, dynamic>?;
    if (jsonData == null) {
      throw Exception('Data [AdobeResponseWrapper] in response is null');
    }

    return AemResponseWrapper(
      data: AemByPathWrapper.fromJsonList(
        jsonData[keyByPath] as Map<String, dynamic>,
        fromJsonT,
      ),
      errors: json.getMappedListOrNull(
        'errors',
        GeneralException.fromJson,
      ),
    );
  }
}

class AemByPathWrapper<T> {
  final T? item;
  final List<T>? items;

  AemByPathWrapper({required this.item, required this.items});

  factory AemByPathWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return AemByPathWrapper(
      item: fromJsonT(json['item'] as Map<String, dynamic>),
      items: null,
    );
  }

  factory AemByPathWrapper.fromJsonList(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) =>
      AemByPathWrapper(
        item: null,
        items: (json['items'] as List)
            .cast<Map<String, dynamic>>()
            .map(fromJsonT)
            .toList(),
      );
}
