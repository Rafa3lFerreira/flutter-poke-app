class Pokemon {
  final String name;
  final int spriteId;
  final List<int> typeIds;
  int level;
  final List<String> moves;

  Pokemon({
    required this.name,
    required this.spriteId,
    required this.typeIds,
    required this.level,
    this.moves = const [],
  });

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$spriteId.png';

  String get typeSpriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-iii/firered-leafgreen/';
}
