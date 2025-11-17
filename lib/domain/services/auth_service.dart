import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyName = 'auth_name';
  static const _keyDeviceId = 'auth_deviceId';
  static const _keyPassword = 'auth_password';
  static const _keyPermissionId = 'auth_permission_id';

  // Salva os dados do usuário
  Future<void> saveAuthData({
    required String token,
    required String email,
    required String name,
    required String deviceId,
    required String password,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyName, value: name);
    await _storage.write(key: _keyDeviceId, value: deviceId);
    await _storage.write(key: _keyPassword, value: password);
  }

  // Salva os dados do usuário anônimo
  Future<void> saveAuthDataAnon({
    required String token,
    required String name,
    required String deviceId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyName, value: name);
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  // 🆕 salva o permissionId
  Future<void> savePermissionId(int permissionId) async {
    await _storage.write(key: _keyPermissionId, value: permissionId.toString());
  }

  // 🆕 recupera o permissionId
  Future<int?> getPermissionId() async {
    final value = await _storage.read(key: _keyPermissionId);
    return value != null ? int.tryParse(value) : null;
  }

  // Recupera os dados padrão
  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getEmail() async => await _storage.read(key: _keyEmail);
  Future<String?> getName() async => await _storage.read(key: _keyName);
  Future<String?> getDeviceId() async => await _storage.read(key: _keyDeviceId);
  Future<String?> getPassword() async => await _storage.read(key: _keyPassword);

  // Verifica se está logado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Limpa todos os dados (logout)
  Future<void> clearAuthData() async => await _storage.deleteAll();
}
