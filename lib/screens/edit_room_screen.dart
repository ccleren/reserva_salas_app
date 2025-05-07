import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRoomScreen extends StatefulWidget {
  final String? roomId;
  final Map<String, dynamic>? initialData;

  const EditRoomScreen({super.key, this.roomId, this.initialData});

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _notesController = TextEditingController(); 
  DateTime? _reservationDateTime;
  String _status = 'confirmada';

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _capacityController.text =
          widget.initialData!['capacity']?.toString() ?? '';
      _notesController.text = widget.initialData!['notes'] ?? '';
      _status = widget.initialData!['status'] ?? 'confirmada';

      if (widget.initialData!['reservationDateTime'] != null) {
        final timestamp = widget.initialData!['reservationDateTime'];
        _reservationDateTime = (timestamp as Timestamp).toDate();
      }
    }
  }

  Future<void> saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    if (_reservationDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar fecha y hora')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final notes = _notesController.text.trim();
    final responsibleName = 'Usuario actual';

    final roomData = {
      'name': name,
      'capacity': capacity,
      'notes': notes,
      'status': _status,
      'responsibleName': responsibleName,
      'reservationDateTime': _reservationDateTime,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final roomsRef = FirebaseFirestore.instance.collection('rooms');

    if (widget.roomId == null) {
      await roomsRef.add({
        ...roomData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await roomsRef.doc(widget.roomId).update(roomData);
    }

    Navigator.pop(context);
  }

  Future<void> pickReservationDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _reservationDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.roomId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar reserva' : 'Nueva reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre de la reserva'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),

              // Capacidad
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),

              // Notas
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notas'),
                maxLines: 2,
              ),

              // Estado de la reserva
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Estado de la reserva'),
                items: const [
                  DropdownMenuItem(value: 'confirmada', child: Text('Confirmada')),
                  DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                  DropdownMenuItem(value: 'completada', child: Text('Completada')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Fecha y hora
              ElevatedButton(
                onPressed: pickReservationDateTime,
                child: Text(
                  _reservationDateTime == null
                      ? 'Seleccionar fecha y hora'
                      : 'Reserva: $_reservationDateTime',
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: saveRoom,
                child: Text(isEditing ? 'Guardar cambios' : 'Crear reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
