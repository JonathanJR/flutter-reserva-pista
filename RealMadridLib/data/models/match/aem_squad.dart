import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemSquad {
  final bool? provisionalSquad;
  final String? name;
  final String? shortName;
  final String? officialName;
  final String? squadLabel;
  final String? provisionalSquadLabel;
  final List<String>? tag;
  final int? sellTicketsLimitTime;

  AemSquad({
    this.provisionalSquad,
    this.name,
    this.shortName,
    this.officialName,
    this.squadLabel,
    this.provisionalSquadLabel,
    this.tag,
    this.sellTicketsLimitTime,
  });

  factory AemSquad.fromJson(Map<String, dynamic> json) => AemSquad(
        provisionalSquad: json.getOrNull('provisionalSquad'),
        name: json.getOrNull('name'),
        shortName: json.getOrNull('shortName'),
        officialName: json.getOrNull('officialName'),
        squadLabel: json.getOrNull('squadLabel'),
        provisionalSquadLabel: json.getOrNull('provisionalSquadLabel'),
        tag: json.getListOrNull('tag'),
        sellTicketsLimitTime: json.getOrNull('sellTicketsLimitTime'),
      );
}
