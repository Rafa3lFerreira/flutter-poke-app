import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _nameController = TextEditingController();
  int _selectedAvatar = 1;
  bool _loading = true;
  bool _saving = false;

  DocumentReference<Map<String, dynamic>> get _profileDoc =>
      FirebaseFirestore.instance.collection('trainer_profile').doc('main');

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
    final doc = await _profileDoc.get();
    if (!mounted) return;

    final data = doc.data();
    setState(() {
      _nameController.text = data?['name'] as String? ?? '';
      _selectedAvatar = (data?['avatarIndex'] as int?) ?? 1;
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final nome = _nameController.text.trim();

    if (nome.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nome deve ter pelo menos 2 caracteres'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    await _profileDoc.set(
      {'name': nome, 'avatarIndex': _selectedAvatar},
      SetOptions(merge: true),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil salvo!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Treinador')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Nome do treinador',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Escolha seu avatar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(6, (i) {
                      final avatarIndex = i + 1;
                      final isSelected = _selectedAvatar == avatarIndex;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedAvatar = avatarIndex),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            'assets/trainers/trainer_$avatarIndex.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
