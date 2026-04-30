class Pokemon {
  final String name;
  final String spriteUrl;
  final List<int> typeIds;
  int level;
  final List<String> moves;

  Pokemon({
    required this.name,
    required this.spriteUrl,
    required this.typeIds,
    required this.level,
    this.moves = const [],
  });

  String get typeSpriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-iii/firered-leafgreen/';
}
