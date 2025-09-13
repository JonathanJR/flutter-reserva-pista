import 'package:flutter/material.dart';
import 'package:rm_app_flutter_core/data/models/value_state.dart';
import 'package:rm_app_flutter_fan/domain/models/match/match.dart';

class NextMatchWidget extends StatelessWidget {
  final ValueState<List<MatchFan>> matches;

  const NextMatchWidget({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (matches.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (matches.hasError) {
      return Center(child: Text('Error al cargar partidos'));
    }
    final matchList = matches.valueOrNull;
    if (matchList == null || matchList.isEmpty) {
      return Center(child: Text('No hay partidos próximos'));
    }
    final nextMatch = matchList.first;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${nextMatch.homeTeam} vs ${nextMatch.awayTeam}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha: ${nextMatch.date.toLocal().toString().substring(0, 16)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Estadio: ${nextMatch.stadium}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Competición: ${nextMatch.competition}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
