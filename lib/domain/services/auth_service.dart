import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _jwtKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _jwtKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _jwtKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _jwtKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
