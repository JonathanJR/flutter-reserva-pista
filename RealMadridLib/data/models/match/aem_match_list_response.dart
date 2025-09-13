import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_match.dart';

class AemMatchListResponse {
  final List<AemMatch>? items;

  AemMatchListResponse({this.items});

  factory AemMatchListResponse.fromJson(Map<String, dynamic> json) =>
      AemMatchListResponse(
        items: json.getMappedListOrNull('items', AemMatch.fromJson),
      );
}
