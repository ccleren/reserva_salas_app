import 'dart:async';

class SimpleUser {
  final String email;
  const SimpleUser(this.email);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  // ─── Singleton ───────────────────────────────────────────────────────
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _controller.add(null); // valor inicial
  }

  // ─── Configuración fija ──────────────────────────────────────────────
  static const _allowedUsers = <String>{
    'carmen@medac.es',
    'antonio@medac.es',
    'javi@medac.es',
    'borja@medac.es',
    'jose@medac.es',
    'jesus@medac.es',
  };
  static const _password = 'Salas123';

  // ─── Estado interno ──────────────────────────────────────────────────
  final _controller = StreamController<SimpleUser?>.broadcast();
  SimpleUser? _currentUser;

  Stream<SimpleUser?> get userChanges => _controller.stream;
  SimpleUser? get currentUser => _currentUser;

  // ─── Login ───────────────────────────────────────────────────────────
  Future<String?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (!_allowedUsers.contains(email.toLowerCase())) {
      throw const AuthException('Correo no autorizado');
    }
    if (password != _password) {
      throw const AuthException('Contraseña incorrecta');
    }

    _currentUser = SimpleUser(email);
    _controller.add(_currentUser);
    return email; // Devolvemos el email como userId
  }

  Future<void> register(String email, String password) =>
      throw const AuthException('Registro deshabilitado');

  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}