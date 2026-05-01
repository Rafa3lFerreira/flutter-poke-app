import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<String>> fetchPokemonNames() async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=20'),
  );
  if (response.statusCode != 200) {
    throw Exception('Erro ${response.statusCode}');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final results = data['results'] as List<dynamic>;
  return results
      .map((item) => (item as Map<String, dynamic>)['name'] as String)
      .toList();
}

Future<List<String>> fetchPokemonByName(String name) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
  );
  if (response.statusCode == 404) {
    throw Exception('Pokémon "$name" não encontrado');
  }
  if (response.statusCode != 200) {
    throw Exception('Erro ${response.statusCode}');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return [data['name'] as String];
}

Future<Map<String, dynamic>> fetchPokemonDetails(String name) async {
  final response = await http.get(
    Uri.parse('https://pokeapi.co/api/v2/pokemon/$name'),
  );
  if (response.statusCode != 200) {
    throw Exception('Erro ${response.statusCode}');
  }
  final data = jsonDecode(response.body) as Map<String, dynamic>;

  final rawTypes = data['types'] as List<dynamic>;
  final types = rawTypes
      .map(
        (t) =>
            ((t as Map<String, dynamic>)['type']
                    as Map<String, dynamic>)['name']
                as String,
      )
      .toList();

  final sprites = data['sprites'] as Map<String, dynamic>;
  final id = data['id'] as int;
  final spriteUrl =
      (sprites['front_default'] as String?) ??
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

  return {
    'name': data['name'] as String,
    'spriteUrl': spriteUrl,
    'types': types,
  };
}
