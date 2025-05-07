import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_room_screen.dart';

class RoomsListScreen extends StatelessWidget {
  const RoomsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roomsRef = FirebaseFirestore.instance.collection('rooms');

    return Scaffold(
      appBar: AppBar(title: const Text('Reservas disponibles')),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditRoomScreen(),
            ),
          );
        },
      ),

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
            return const Center(child: Text('⚠️ No hay reservas disponibles'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final room = docs[index];
              final data = room.data() as Map<String, dynamic>;
              final dateTime = data['reservationDateTime'] != null
                  ? (data['reservationDateTime'] as Timestamp).toDate().toLocal()
                  : null;

              final String status = data['status'] ?? 'sin estado';

              return ListTile(
                title: Text(data['name'] ?? 'Reserva sin nombre'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notas: ${data['notes'] ?? '—'}'),
                    Text('Capacidad: ${data['capacity'] ?? 'desconocida'}'),
                    if (dateTime != null)
                      Text('Fecha: $dateTime',
                          style: const TextStyle(fontSize: 12)),

                    const SizedBox(height: 4),

                    // Chip con estado coloreado
                    Chip(
                      label: Text(
                        status.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      avatar: Icon(
                        status == 'confirmada'
                            ? Icons.check_circle
                            : status == 'cancelada'
                                ? Icons.cancel
                                : Icons.done_all,
                        color: Colors.white,
                        size: 18,
                      ),
                      backgroundColor: status == 'confirmada'
                          ? Colors.green
                          : status == 'cancelada'
                              ? Colors.red
                              : Colors.blueGrey,
                    ),

                    const SizedBox(height: 4),
                    Text('Responsable: ${data['responsibleName'] ?? '—'}'),
                  ],
                ),
                isThreeLine: true,

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditRoomScreen(
                              roomId: room.id,
                              initialData: data,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('¿Eliminar reserva?'),
                            content: const Text(
                                'Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await roomsRef.doc(room.id).delete();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

