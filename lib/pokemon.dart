class Pokemon {
  final String name;
  final String spriteUrl;
  final List<String> types;
  int level;
  final List<String> moves;
  final double? latitude;
  final double? longitude;

  Pokemon({
    required this.name,
    required this.spriteUrl,
    required this.types,
    required this.level,
    this.moves = const [],
    this.latitude,
    this.longitude,
  });

  bool get hasLocation => latitude != null && longitude != null;
}
