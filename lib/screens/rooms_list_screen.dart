import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_reservation_screen.dart'; // Asegúrate de que esta ruta es correcta según tu estructura

class RoomsListScreen extends StatelessWidget {
  const RoomsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomsRef = FirebaseFirestore.instance.collection('rooms');

    return Scaffold(
      appBar: AppBar(title: const Text('Salas disponibles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: roomsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
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
                title: Text(
                  data.containsKey('name') ? data['name'] : 'Sala sin nombre',
                ),
                subtitle: Text(
                  data.containsKey('capacity')
                      ? 'Capacidad: ${data['capacity']}'
                      : 'Capacidad desconocida',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddReservationPage(
                          roomId: room.id,
                          roomName: data['name'] ?? 'Sala sin nombre',
                        ),
                      ),
                    );
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

