import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddReservationPage extends StatefulWidget {
  final String roomId;
  final String roomName;

  AddReservationPage({required this.roomId, required this.roomName});

  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  String? selectedUserId;
  String? selectedUserName;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;

  final usersRef = FirebaseFirestore.instance.collection('users');
  final reservationsRef = FirebaseFirestore.instance.collection('reservations');

  Future<void> pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 10, minute: 0),
    );
    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isStart) {
        selectedStartTime = dateTime;
      } else {
        selectedEndTime = dateTime;
      }
    });
  }

  void saveReservation() async {
    if (selectedUserId == null ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    await reservationsRef.add({
      'roomId': widget.roomId,
      'roomName': widget.roomName,
      'userId': selectedUserId,
      'userName': selectedUserName,
      'startTime': selectedStartTime,
      'endTime': selectedEndTime,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'notes': '',
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva reserva: ${widget.roomName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Selecciona un usuario:'),
            StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: selectedUserId,
                  hint: Text('Usuario'),
                  items:
                      docs.map((doc) {
                        final id = doc.id;
                        final name = doc['name'];
                        return DropdownMenuItem(
                          value: id,
                          child: Text(name),
                          onTap: () => selectedUserName = name,
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => selectedUserId = val),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => pickDateTime(true),
              child: Text(
                selectedStartTime == null
                    ? 'Elegir hora de inicio'
                    : 'Inicio: $selectedStartTime',
              ),
            ),
            ElevatedButton(
              onPressed: () => pickDateTime(false),
              child: Text(
                selectedEndTime == null
                    ? 'Elegir hora de fin'
                    : 'Fin: $selectedEndTime',
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: saveReservation,
              child: Text('Guardar reserva'),
            ),
          ],
        ),
      ),
    );
  }
}
