import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemVenue {
  final String? optaId;
  final String? name;
  final String? country;

  AemVenue({this.optaId, this.name, this.country});

  factory AemVenue.fromJson(Map<String, dynamic> json) => AemVenue(
        optaId: json.getOrNull('optaId'),
        name: json.getOrNull('name'),
        country: json.getOrNull('country'),
      );
}
