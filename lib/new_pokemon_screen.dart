import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'location_service.dart';
import 'pokemon_service.dart';

class PokemonForm extends StatefulWidget {
  const PokemonForm({super.key});

  @override
  State<PokemonForm> createState() => _PokemonFormState();
}

class _PokemonFormState extends State<PokemonForm> {
  final _formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  final _levelController = TextEditingController();
  late Future<List<String>> _searchFuture;
  Map<String, dynamic>? _selected;
  bool _loadingDetails = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonNames();
  }

  @override
  void dispose() {
    _queryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _buscar() {
    final query = _queryController.text.trim();
    setState(() {
      _searchFuture = query.isEmpty
          ? fetchPokemonNames()
          : fetchPokemonByName(query);
    });
  }

  Future<void> _selectPokemon(String name) async {
    setState(() => _loadingDetails = true);
    try {
      final details = await fetchPokemonDetails(name);
      if (!mounted) return;
      setState(() {
        _selected = details;
        _loadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingDetails = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _capturar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _capturing = true);
    final position = await getLocation();

    await FirebaseFirestore.instance.collection('pokemons').add({
      'name': _selected!['name'],
      'spriteUrl': _selected!['spriteUrl'],
      'types': _selected!['types'],
      'level': int.parse(_levelController.text.trim()),
      if (position != null) 'latitude': position.latitude,
      if (position != null) 'longitude': position.longitude,
    });

    if (!mounted) return;
    setState(() => _capturing = false);

    final mensagem = position != null
        ? 'Capturado em ${position.latitude.toStringAsFixed(4)}°, ${position.longitude.toStringAsFixed(4)}°'
        : 'Capturado sem localização';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pokémon')),
      body: _loadingDetails
          ? const Center(child: CircularProgressIndicator())
          : (_selected == null ? _buildList() : _buildForm()),
    );
  }

  Widget _buildList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Buscar por nome',
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _buscar, child: const Text('Buscar')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }
                final names = snapshot.data ?? const <String>[];
                if (names.isEmpty) {
                  return const Center(
                    child: Text('Nenhum Pokémon encontrado'),
                  );
                }
                return ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    final name = names[index];
                    return ListTile(
                      title: Text(name),
                      onTap: () => _selectPokemon(name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Image.network(
                      _selected!['spriteUrl'] as String,
                      width: 72,
                      height: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selected!['name'] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selected = null),
                      child: const Text('Trocar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: (_selected!['types'] as List<dynamic>)
                  .map((t) => Chip(label: Text(t as String)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _levelController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nível inicial',
              ),
              validator: (value) {
                final text = value?.trim() ?? '';
                if (text.isEmpty) return 'Campo obrigatório';
                final n = int.tryParse(text);
                if (n == null) return 'Informe um número inteiro';
                if (n < 1 || n > 100) return 'Deve estar entre 1 e 100';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ao capturar, o navegador pode pedir permissão para acessar sua localização.',
                      style: TextStyle(
                        color: Colors.deepPurple.shade900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _capturing ? null : _capturar,
              icon: _capturing
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.catching_pokemon),
              label: Text(_capturing ? 'Capturando...' : 'Capturar Pokémon'),
            ),
          ],
        ),
      ),
    );
  }
}
