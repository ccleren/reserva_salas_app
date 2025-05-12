class RoomSearchDelegate extends SearchDelegate<String> {
  @override
  Widget buildResults(BuildContext context) {
    final stream = RoomsQueryBuilder.build(textQuery: query).snapshots();
    return StreamBuilder<QuerySnapshot>( … );   // Renderiza tarjetas
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const Center(child: Text('Empieza a escribir…'));
    final stream = RoomsQueryBuilder.build(textQuery: query).limit(5).snapshots();
    return StreamBuilder<QuerySnapshot>( … );   // Lista corta tipo “sugerencia”
  }

  // Ícono de “clear”
  @override
  List<Widget> buildActions(BuildContext ctx) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.close), onPressed: () => query = ''),
      ];
}

