import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_img.dart';

class AemTeam {
  final String? optaId;
  final String? name;
  final String? shortName;
  final String? officialName;
  final String? code;
  final AemImg? logo;

  AemTeam({
    this.optaId,
    this.name,
    this.shortName,
    this.officialName,
    this.code,
    this.logo,
  });

  factory AemTeam.fromJson(Map<String, dynamic> json) => AemTeam(
        optaId: json.getOrNull('optaId'),
        name: json.getOrNull('name'),
        shortName: json.getOrNull('shortName'),
        officialName: json.getOrNull('officialName'),
        code: json.getOrNull('code'),
        logo: json.getMappedOrNull('logo', AemImg.fromJson),
      );
}
