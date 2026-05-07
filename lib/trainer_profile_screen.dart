import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreen();
}

class _TrainerProfileScreen extends State<TrainerProfileScreen> {

    final _nameController = TextEditingController();

    @override
    void initState() {
        super.initState();
        _loadProfile();
    }

    Future<void> _loadProfile() async {
        final doc = await FirebaseFirestore.instance
            .collection('config')
            .doc('')
            .get();
        if (doc.exists) {
            final data = doc.data()!;
            setState(() {
                _nameController.text = data['name'] as String? ?? '';
                _selectedAvatar = data['avatarIndex'] as int? ?? 0;
            })
        }
    }

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
                )
              )
            ]
          )
        ]
      )
    )
}