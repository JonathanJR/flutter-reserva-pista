import 'package:rm_app_flutter_fan/core/constants/squad_constants.dart';
import 'package:rm_app_flutter_fan/domain/models/match/sport.dart';


class SquadLocal {
  final SportType sport;
  final String optaId;

  SquadLocal({required this.sport, required this.optaId});

  factory SquadLocal.mensFootballFirst() {
    return SquadLocal(
      sport: SportType.football,
      optaId: SquadConstants.mensFootballFirstOptaId,
    );
  }
}
