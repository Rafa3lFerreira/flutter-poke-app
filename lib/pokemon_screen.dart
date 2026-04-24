import 'package:flutter/material.dart';
import 'pokemon.dart';

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
    return Scaffold(
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
            BattlePanel(pokemon: widget.pokemon),
            SizedBox(height: 16),
            MoveList(pokemon: widget.pokemon),
          ],
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
                Row(
                  children: [
                    for (var tipos in widget.pokemon.typeIds)
                      Image.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-iii/firered-leafgreen/$tipos.png',
                        height: 12,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePanel extends StatefulWidget {
  final Pokemon pokemon;

  const BattlePanel({super.key, required this.pokemon});

  @override
  State<BattlePanel> createState() => _BattlePanelState();
}

class _BattlePanelState extends State<BattlePanel> {
  int hp = 100;
  int xp = 0;
  late int level;

  @override
  void initState() {
    super.initState();
    level = widget.pokemon.level;
  }

  Color get hpColor {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.yellow;
    return Colors.red;
  }

  String get statusMessage {
    if (hp == 0) return '${widget.pokemon.name} desmaiou!';
    if (hp <= 30) return 'HP crítico!';
    return '';
  }

  void _atacar() {
    setState(() {
      hp = (hp - 20).clamp(0, 100);
      xp = xp + 10;
      if (xp >= 100) {
        level++;
        xp = 0;
      }
    });
  }

  void _usarPocao() {
    setState(() {
      hp = (hp + 30).clamp(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Nível $level',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _StatBar(label: 'HP', value: hp, maxValue: 100, color: hpColor),
            _StatBar(label: 'XP', value: xp, maxValue: 100, color: Colors.blue),
            if (statusMessage.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                statusMessage,
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
                    onPressed: hp > 0 ? _atacar : null,
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
                    onPressed: hp < 100 ? _usarPocao : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Usar Poção'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, level),
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

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label   $value / $maxValue',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
          SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = (value / maxValue).clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
