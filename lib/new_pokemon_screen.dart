import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon_service.dart';

class PokemonForm extends StatefulWidget {
  const PokemonForm({super.key});

  @override
  State<PokemonForm> createState() => _PokemonFormState();
}

class _PokemonFormState extends State<PokemonForm> {
  final _formKey = GlobalKey<FormState>();
  final _levelController = TextEditingController();
  bool _loadingDetails = false;
  final _queryController = TextEditingController();
  final _levelFocusNode = FocusNode();
  Map<String, dynamic>? _selected; // null = fase 1, não-null = fase 2
  late Future<List<String>> _searchFuture;

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonNames();
  }

  void _buscar() {
    setState(() {
      _searchFuture = fetchPokemonByName(_queryController.text.trim());
    });
  }

  void dispose() {
    _nameController.dispose();
    _spriteIdController.dispose();
    _levelController.dispose();
    _spriteIdFocusNode.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection('pokemons').add({
      'name': _nameController.text.trim(),
      'spriteId': _spriteIdController.text.trim(),
      'level': int.parse(_levelController.text.trim()),
      'types': <String>[_selectedType!],
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pokémon')),
      body: _selected == null ? _buildList() : _buildForm(),
    );
  }
}

/* Padding( padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_previewName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Cadastrando: $_previewName…',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _spriteIdFocusNode.requestFocus(),
                onChanged: (value) =>
                    setState(() => _previewName = value.trim()),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome do Pokémon',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Campo obrigatório';
                  if (text.length < 2) return 'Mínimo 2 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _spriteIdController,
                focusNode: _spriteIdFocusNode,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _levelFocusNode.requestFocus(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sprite ID',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Campo obrigatório';
                  final n = int.tryParse(text);
                  if (n == null) return 'Informe um número inteiro';
                  if (n < 1 || n > 1025) return 'Deve estar entre 1 e 1025';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _levelController,
                focusNode: _levelFocusNode,
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
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'Fogo',
                          'Água',
                          'Planta',
                          'Elétrico',
                          'Normal',
                          'Psíquico',
                          'Gelo',
                          'Dragão',
                        ]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) =>
                    value == null ? 'Selecione um tipo' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _save, child: const Text('Salvar')),
            ],
          ),
        ),
      ),  */
