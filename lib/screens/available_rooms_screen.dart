import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableRoomsScreen extends StatelessWidget {
  const AvailableRoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableRoomsRef = FirebaseFirestore.instance
        .collection('rooms')
        .where('status', isEqualTo: 'disponible'); // Solo salas disponibles

    return Scaffold(
      appBar: AppBar(title: const Text('Salas disponibles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: availableRoomsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('⚠️ No hay salas disponibles'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final room = docs[index];
              final data = room.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? 'Sala sin nombre'),
                subtitle: Text(
                  'Capacidad: ${data['capacity'] ?? 'desconocida'}',
                ),
                trailing: const Icon(Icons.meeting_room),
              );
            },
          );
        },
      ),
    );
  }
}
