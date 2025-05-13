import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
// Importa Firebase Auth (si lo usas)

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();

  void _showError(Object e) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));

  Future<String?> getFirebaseMessagingToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      String? token = await messaging.getToken();
      print('FCM registration token: $token');
      return token;
    } else {
      print('User declined or has not granted permission.');
      return null;
    }
  }

  Future<void> saveUserTokenToFirestore(String userId, String? fcmToken) async {
  if (fcmToken != null) {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'fcmToken': fcmToken,
    }, SetOptions(merge: true));
  }
}

  Future<void> _saveTokenAfterLogin(String userId) async {
    String? fcmToken = await getFirebaseMessagingToken();
    if (fcmToken != null) {
      await saveUserTokenToFirestore(userId, fcmToken);
      // Navegar a la siguiente pantalla después de guardar el token
      Navigator.pushReplacementNamed(context, '/rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final userId =
                        await _auth.signIn(_email.text.trim(), _pass.text.trim());
                    if (userId != null) {
                      await _saveTokenAfterLogin(userId);
                    }
                  } catch (e) {
                    _showError(e);
                  }
                },
                child: const Text('Entrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}