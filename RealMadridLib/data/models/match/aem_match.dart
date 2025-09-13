import 'package:equatable/equatable.dart';
import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_competition.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_description_match.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_squad.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_team.dart';
import 'package:rm_app_flutter_fan/data/models/match/aem_venue.dart';

class AemMatch extends Equatable {
  final String? id;
  final String? optaId;
  final String? optaLegacyId;
  final String? slug;
  final DateTime? dateTime;
  final String? status;
  final bool? isScheduled;
  final bool playAsHome;
  final bool? soldOut;
  final String? homeTeamScoreTotal;
  final String? homeTeamPenaltiesScoreTotal;
  final String? awayTeamScoreTotal;
  final String? awayTeamPenaltiesScoreTotal;
  final List<String>? homeScorers;
  final List<String>? awayScorers;
  final AemCompetition? competition;
  final AemTeam? homeTeam;
  final AemTeam? awayTeam;
  final AemVenue? venue;
  final AemDescriptionMatch? description;
  final String? week;
  final AemSquad? squad;
  final String? path;

  const AemMatch({
    this.id,
    this.optaId,
    this.optaLegacyId,
    this.slug,
    this.dateTime,
    this.status,
    this.isScheduled,
    this.playAsHome = false,
    this.soldOut,
    this.homeTeamScoreTotal,
    this.homeTeamPenaltiesScoreTotal,
    this.awayTeamScoreTotal,
    this.awayTeamPenaltiesScoreTotal,
    this.homeScorers,
    this.awayScorers,
    this.competition,
    this.homeTeam,
    this.awayTeam,
    this.venue,
    this.description,
    this.week,
    this.squad,
    this.path,
  });

  @override
  List<Object?> get props => [optaId];

  factory AemMatch.fromJson(Map<String, dynamic> json) => AemMatch(
        id: json.getOrNull('id'),
        optaId: json.getOrNull('optaId'),
        optaLegacyId: json.getOrNull('optaLegacyId'),
        slug: json.getOrNull('slug'),
        dateTime: json.getMappedOrNull('dateTime', DateTime.parse),
        status: json.getOrNull('status'),
        isScheduled: json.getOrNull('isScheduled'),
        playAsHome: json.getOrNull('playAsHome') ?? false,
        soldOut: json.getOrNull('soldOut'),
        homeTeamScoreTotal: json.getOrNull('homeTeamScoreTotal'),
        homeTeamPenaltiesScoreTotal:
            json.getOrNull('homeTeamPenaltiesScoreTotal'),
        awayTeamScoreTotal: json.getOrNull('awayTeamScoreTotal'),
        awayTeamPenaltiesScoreTotal:
            json.getOrNull('awayTeamPenaltiesScoreTotal'),
        homeScorers: json.getListOrNull('homeScorers'),
        awayScorers: json.getListOrNull('awayScorers'),
        competition:
            json.getMappedOrNull('competition', AemCompetition.fromJson),
        homeTeam: json.getMappedOrNull('homeTeam', AemTeam.fromJson),
        awayTeam: json.getMappedOrNull('awayTeam', AemTeam.fromJson),
        venue: json.getMappedOrNull('venue', AemVenue.fromJson),
        description:
            json.getMappedOrNull('description', AemDescriptionMatch.fromJson),
        week: json.getOrNull('week'),
        squad: json.getMappedOrNull('squad', AemSquad.fromJson),
        path: json.getOrNull('_path'),
      );
}
