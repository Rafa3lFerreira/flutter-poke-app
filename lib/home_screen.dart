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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pokédex', style: TextStyle(fontSize: 18)),
            Text(
              FirebaseAuth.instance.currentUser?.email,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('trainer_profile')
                .doc('main')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(child: Icon(Icons.person)),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>?;
              final avatarIndex = data?['avatarIndex'] ?? 0;

              return IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TrainerProfileScreen(),
                    ),
                  );
                },
                icon: CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/trainers/trainer_$avatarIndex.png',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
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
