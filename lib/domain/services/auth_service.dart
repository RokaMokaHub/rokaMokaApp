import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';

  // Salva os dados do usuário
  Future<void> saveAuthData({
    required String token,
    required String email,
    required String name,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyName, value: name);
  }

  // Recupera os dados
  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getEmail() async => await _storage.read(key: _keyEmail);
  Future<String?> getName() async => await _storage.read(key: _keyName);

  // Verifica se está logado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Limpa todos os dados (logout)
  Future<void> clearAuthData() async => await _storage.deleteAll();
}
