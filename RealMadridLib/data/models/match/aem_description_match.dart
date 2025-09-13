import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemDescriptionMatch {
  final String? plaintext;

  AemDescriptionMatch({this.plaintext});

  factory AemDescriptionMatch.fromJson(Map<String, dynamic> json) =>
      AemDescriptionMatch(
        plaintext: json.getOrNull('plaintext'),
      );
}
