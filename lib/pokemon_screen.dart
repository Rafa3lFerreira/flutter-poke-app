import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pokemon.dart';
import 'battle_provider.dart';
import 'stat_bar.dart';

class PokemonScreen extends StatefulWidget {
  final Pokemon pokemon;
  final String docId;

  const PokemonScreen({super.key, required this.pokemon, required this.docId});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BattleProvider(
        pokemonName: widget.pokemon.name,
        level: widget.pokemon.level,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: Text(widget.pokemon.name),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PokemonCard(pokemon: widget.pokemon),
              SizedBox(height: 16),
              LocationCard(pokemon: widget.pokemon),
              SizedBox(height: 16),
              BattlePanel(docId: widget.docId),
              SizedBox(height: 16),
              MoveList(pokemon: widget.pokemon),
            ],
          ),
        ),
      ),
    );
  }
}

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> {
  @override
  Widget build(BuildContext context) {
    final level = context.select((BattleProvider p) => p.level);
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: NetworkImage(widget.pokemon.spriteUrl),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pokemon.name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Nível $level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: widget.pokemon.types
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final Pokemon pokemon;

  const LocationCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final hasLocation = pokemon.hasLocation;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              hasLocation ? Icons.place : Icons.location_off,
              color: hasLocation ? Colors.deepPurple : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Local da captura',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasLocation
                        ? '${pokemon.latitude!.toStringAsFixed(4)}°, ${pokemon.longitude!.toStringAsFixed(4)}°'
                        : 'Localização não registrada',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePanel extends StatelessWidget {
  final String docId;

  const BattlePanel({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    final battle = context.watch<BattleProvider>();
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Nível ${battle.level}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            StatBar(
              label: 'HP',
              value: battle.hp,
              maxValue: 100,
              color: battle.hpColor,
            ),
            StatBar(
              label: 'XP',
              value: battle.xp,
              maxValue: 100,
              color: Colors.blue,
            ),
            if (battle.statusMessage.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                battle.statusMessage,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: battle.hp > 0
                        ? () => context.read<BattleProvider>().attack()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Atacar'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: battle.hp < 100
                        ? () => context.read<BattleProvider>().heal()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Usar Poção'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final level = context.read<BattleProvider>().level;
                      Navigator.pop(context, level);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Encerrar batalha'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MoveList extends StatefulWidget {
  final Pokemon pokemon;
  const MoveList({super.key, required this.pokemon});

  @override
  State<MoveList> createState() => _MoveListState();
}

class _MoveListState extends State<MoveList> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Golpes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          for (var golpes in widget.pokemon.moves)
            ListTile(
              leading: Icon(Icons.nightlight_round, color: Colors.deepPurple),
              title: Text(golpes),
            ),
        ],
      ),
    );
  }
}
