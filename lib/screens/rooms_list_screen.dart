import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/rooms_query_builder.dart';
import '../widgets/room_search_delegate.dart';
import 'all_reservations_screen.dart';
import 'edit_room_screen.dart';

class RoomsListScreen extends StatefulWidget {
  const RoomsListScreen({super.key});

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  String selectedStatus = 'Todas';
  final List<String> statusOptions = ['Todas', 'ocupada', 'disponible'];

  int selectedMinCapacity = 0;
  final List<int> capacityOptions = [0, 5, 10, 20, 30, 40];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salas de trabajo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RoomSearchDelegate(),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'Menú principal',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Reservas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllReservationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditRoomScreen()),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              items: statusOptions.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status[0].toUpperCase() + status.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<int>(
              value: selectedMinCapacity,
              items: capacityOptions.map((cap) {
                return DropdownMenuItem<int>(
                  value: cap,
                  child: Text(
                    cap == 0 ? 'Todas las capacidades' : 'Capacidad > $cap',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedMinCapacity = value!;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: RoomsQueryBuilder.build(
                      status: selectedStatus == 'Todas' ? null : selectedStatus,
                      minCapacity: selectedMinCapacity == 0
                          ? null
                          : selectedMinCapacity)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('❌ Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final statusMatches = selectedStatus == 'Todas' ||
                      data['status'] == selectedStatus;

                  final capacity = data['capacity'] ?? 0;
                  final capacityMatches =
                      capacity is int && capacity > selectedMinCapacity;

                  return statusMatches && capacityMatches;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('⚠️ No hay salas con ese filtro'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final room = filteredDocs[index];
                    final data = room.data() as Map<String, dynamic>;
                    final dateTime = data['reservationDateTime'] != null
                        ? (data['reservationDateTime'] as Timestamp)
                            .toDate()
                            .toLocal()
                        : null;

                    final String status = data['status'] ?? 'sin estado';

                    Color chipColor;
                    IconData chipIcon;

                    switch (status) {
                      case 'confirmada':
                        chipColor = Colors.green;
                        chipIcon = Icons.check_circle;
                        break;
                      case 'cancelada':
                        chipColor = Colors.red;
                        chipIcon = Icons.cancel;
                        break;
                      case 'completada':
                        chipColor = Colors.blue;
                        chipIcon = Icons.done;
                        break;
                      default:
                        chipColor = Colors.grey;
                        chipIcon = Icons.help;
                    }

                    return ListTile(
                      title: Text(data['name'] ?? 'Reserva sin nombre'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Notas: ${data['notes'] ?? '—'}'),
                          Text(
                            'Capacidad: ${data['capacity'] ?? 'desconocida'}',
                          ),
                          if (dateTime != null)
                            Text(
                              'Fecha: $dateTime',
                              style: const TextStyle(fontSize: 12),
                            ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              status.toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            avatar: Icon(
                              chipIcon,
                              color: Colors.white,
                              size: 18,
                            ),
                            backgroundColor: chipColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Responsable: ${data['responsibleName'] ?? '—'}',
                          ),
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
                                    'Esta acción no se puede deshacer.',
                                  ),
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
                                await FirebaseFirestore.instance
                                    .collection('rooms')
                                    .doc(room.id)
                                    .delete();
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
          ),
        ],
      ),
    );
  }
}