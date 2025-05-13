import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/rooms_list_screen.dart'; // tu pantalla principal
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon'); // El nombre del icono en android/app/src/main/res/drawable

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  runApp(const MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _showLocalNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'reservation_notifications_channel', // ID del canal (único)
    'Reservas', // Nombre del canal
    channelDescription: 'Notificaciones sobre reservas', // Descripción del canal
    importance: Importance.high,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0, // ID de la notificación (único para cada notificación si necesitas actualizarla)
    title,
    body,
    platformChannelSpecifics,
    payload: payload,
  );
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
              ? const RoomsListScreen() // usuario autenticado
              : const LoginPage(); // no autenticado
        },
      ),
    );
  }
}
