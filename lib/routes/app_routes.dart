import 'package:flutter/material.dart';
import 'package:reserva_salas_app/screens/rooms_list_screen.dart';

class AppRoutes {
  static const String rooms = '/rooms';

  static Map<String, WidgetBuilder> routes = {
    rooms: (context) => const RoomsListScreen(),
  
  };
}
