import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/rooms_query_builder.dart'; 

class RoomSearchDelegate extends SearchDelegate<String?> {
  @override
  Widget buildResults(BuildContext context) {
    final stream = RoomsQueryBuilder.build(textQuery: query).snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No se encontraron salas.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? 'Sin nombre'),
              // Aquí puedes mostrar más información de la sala
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Empieza a escribir para buscar salas…'));
    }
    final stream = RoomsQueryBuilder.build(textQuery: query).limit(5).snapshots();
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Algo salió mal'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No se encontraron sugerencias.'));
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name'] ?? 'Sin nombre'),
              onTap: () {
                close(context, data['name']); // Devuelve el nombre seleccionado
              },
            );
          }).toList(),
        );
      },
    );
  }

  // Ícono de “clear”
  @override
  List<Widget> buildActions(BuildContext ctx) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.close), onPressed: () => query = ''),
      ];
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }
}