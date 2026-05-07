import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';
import 'new_pokemon_screen.dart';
import 'trainer_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PokemonForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final docId = docs[index].id;
              final pokemon = Pokemon(
                name: data['name'],
                spriteUrl: data['spriteUrl'],
                types: List<String>.from(data['types'] ?? []),
                level: data['level'],
                moves: List<String>.from(data['moves'] ?? []),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: pokemon.spriteUrl.isNotEmpty
                      ? NetworkImage(pokemon.spriteUrl)
                      : null,
                  child: pokemon.spriteUrl.isEmpty
                      ? const Icon(Icons.catching_pokemon)
                      : null,
                ),
                title: Text(pokemon.name),
                subtitle: Text('Nível: ${pokemon.level}'),
                onTap: () async {
                  final result = await Navigator.push<int>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PokemonScreen(pokemon: pokemon, docId: docId),
                    ),
                  );
                  if (result != null) {
                    await collection.doc(docId).update({'level': result});
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await collection.doc(docId).delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
