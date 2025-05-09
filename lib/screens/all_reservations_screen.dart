import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllReservationsScreen extends StatefulWidget {
  const AllReservationsScreen({super.key});

  @override
  State<AllReservationsScreen> createState() => _AllReservationsScreenState();
}

class _AllReservationsScreenState extends State<AllReservationsScreen> {
  String selectedStatus = 'Todas';
  final List<String> statusOptions = ['Todas', 'activa', 'finalizada'];
  Future<void> actualizarEstadoSala(String roomId) async {
    final now = DateTime.now();

    final snapshot =
        await FirebaseFirestore.instance
            .collection('reservations')
            .where('roomId', isEqualTo: roomId)
            .where('status', isEqualTo: 'activa')
            .where('endTime', isGreaterThan: now)
            .get();

    final tieneReservasActivas = snapshot.docs.isNotEmpty;

    await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
      'status': tieneReservasActivas ? 'ocupada' : 'disponible',
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationsRef = FirebaseFirestore.instance.collection(
      'reservations',
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Todas las reservas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              items:
                  statusOptions.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status == 'Todas'
                            ? 'Todas las reservas'
                            : status[0].toUpperCase() + status.substring(1),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  reservationsRef
                      .orderBy('startTime', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('❌ Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filteredDocs =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return selectedStatus == 'Todas' ||
                          data['status'] == selectedStatus;
                    }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text('⚠️ No hay reservas con ese estado'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final Timestamp? endTimestamp = data['endTime'];
                    final String currentStatus = data['status'] ?? '';

                    // ✅ Si la reserva está activa y la hora ya pasó, actualiza en Firestore
                    if (currentStatus == 'activa' &&
                        endTimestamp != null &&
                        endTimestamp.toDate().isBefore(DateTime.now())) {
                      print('✔️ Actualizando reserva ${doc.id} a finalizada');

                      FirebaseFirestore.instance
                          .collection('reservations')
                          .doc(doc.id)
                          .update({'status': 'finalizada'})
                          .then((_) {
                            final roomId = data['roomId'];
                            if (roomId != null) {
                              actualizarEstadoSala(roomId);
                            }
                          })
                          .catchError((error) {
                            print('❌ Error al actualizar: $error');
                          });
                    }
                    final startTime =
                        data['startTime'] != null
                            ? (data['startTime'] as Timestamp)
                                .toDate()
                                .toLocal()
                            : null;
                    final endTime =
                        data['endTime'] != null
                            ? (data['endTime'] as Timestamp).toDate().toLocal()
                            : null;
                    final createdAt =
                        data['createdAt'] != null
                            ? (data['createdAt'] as Timestamp)
                                .toDate()
                                .toLocal()
                            : null;

                    final roomName = data['roomName'] ?? 'Sin nombre';
                    final userName = data['userName'] ?? 'Usuario desconocido';
                    final notes = data['notes'] ?? 'Sin notas';
                    final status = data['status'] ?? 'sin estado';

                    Color statusColor;
                    switch (status) {
                      case 'active':
                        statusColor = Colors.green;
                        break;
                      case 'finalizada':
                        statusColor = Colors.blue;
                        break;
                      case 'cancelled':
                        statusColor = Colors.red;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(roomName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Responsable: $userName'),
                            if (startTime != null) Text('Inicio: $startTime'),
                            if (endTime != null) Text('Fin: $endTime'),
                            Text('Notas: $notes'),
                            Text(
                              'Estado: $status',
                              style: TextStyle(color: statusColor),
                            ),
                            if (createdAt != null)
                              Text(
                                'Creado: $createdAt',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        isThreeLine: true,
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
