import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() =>
      _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {

  final _nameController = TextEditingController();

  int _selectedAvatar = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        _nameController.text =
            data['name'] as String? ?? '';

        _selectedAvatar =
            data['avatarIndex'] as int? ?? 0;
      });
    }
  }

  Future<void> _saveProfile() async {
    final nome = _nameController.text.trim();

    if (nome.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nome deve ter pelo menos 2 caracteres',
          ),
        ),
      );

      return;
    }

    await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .set(
      {
        'name': nome,
        'avatarIndex': _selectedAvatar,
      },
      SetOptions(merge: true),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil salvo!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Treinador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nome do treinador',
              ),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              children: List.generate(6, (i) {

                final isSelected =
                    _selectedAvatar == i;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatar = i;
                    });
                  },

                  child: Container(
                    margin: const EdgeInsets.all(8),

                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.red
                            : Colors.transparent,
                        width: 3,
                      ),

                      borderRadius:
                          BorderRadius.circular(8),
                    ),

                    child: Image.asset(
                      'assets/trainers/trainer_${i + 1}.png',
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
