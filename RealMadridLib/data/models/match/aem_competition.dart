import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_img.dart';

class AemCompetition {
  final String? optaId;
  final String? name;
  final AemImg? logo;

  AemCompetition({this.optaId, this.name, this.logo});

  factory AemCompetition.fromJson(Map<String, dynamic> json) => AemCompetition(
        optaId: json.getOrNull('optaId'),
        name: json.getOrNull('name'),
        logo: json.getMappedOrNull('logo', AemImg.fromJson),
      );
}
