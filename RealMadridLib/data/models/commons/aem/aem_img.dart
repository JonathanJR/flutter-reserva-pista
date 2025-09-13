import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemImg {
  String publishUrl;
  String? dynamicUrl;

  AemImg({
    required this.publishUrl,
    this.dynamicUrl,
  });

  factory AemImg.fromJson(Map<String, dynamic> json) => AemImg(
        publishUrl: json.getOrThrow('_publishUrl'),
        dynamicUrl: json.getOrNull('_dynamicUrl'),
      );
}
