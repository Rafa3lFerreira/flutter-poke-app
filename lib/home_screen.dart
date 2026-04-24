import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';

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
      appBar: AppBar(title: const Text('Pokédex')),
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
                spriteId: data['spriteId'],
                typeIds: List<int>.from(data['typeIds'] ?? []),
                level: data['level'],
                moves: List<String>.from(data['moves'] ?? []),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage(pokemon.spriteUrl),
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
