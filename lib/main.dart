import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'screens/login_page.dart';
import 'screens/rooms_list_screen.dart'; // tu pantalla principal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reserva de Salas',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: StreamBuilder<SimpleUser?>(
        stream: AuthService().userChanges,
        initialData: null, // evita el spinner infinito
        builder: (context, snapshot) {
          return snapshot.hasData
              ? const RoomsScreen() // usuario autenticado
              : const LoginPage(); // no autenticado
        },
      ),
    );
  }
}
