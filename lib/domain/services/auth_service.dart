import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';

//Classe de autenticação do usuário localmente
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyEmail = 'auth_email';
  static const _keyUserName = 'auth_userName';
  static const _keyDeviceId = 'auth_deviceId';
  static const _keyFirstName = 'auth_firstName';
  static const _keyLastName = 'auth_lastName';

  // Salva os dados do usuário
  Future<void> saveAuthData({
    required String token,
    required String email,
    required String userName,
    required String deviceId,
    required String firstName,
    required String lastName,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyUserName, value: userName);
    await _storage.write(key: _keyDeviceId, value: deviceId);
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
  }

  // Salva os dados do usuário anonimo
  Future<void> saveAuthDataAnon({
    required String token,
    required String userName,
    required String deviceId,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyUserName, value: userName);
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  // Recupera os dados
  Future<String?> getToken() async => await _storage.read(key: _keyToken);
  Future<String?> getEmail() async => await _storage.read(key: _keyEmail);
  Future<String?> getUserName() async => await _storage.read(key: _keyUserName);
  Future<String?> getDeviceId() async => await _storage.read(key: _keyDeviceId);
  Future<String?> getFirstName() async =>
      await _storage.read(key: _keyFirstName);
  Future<String?> getLastName() async => await _storage.read(key: _keyLastName);

  // Verifica se está logado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Lê o cargo efetivo embutido no JWT armazenado (claim `scope`).
  ///
  /// O `scope` é definido pelo backend no login e representa a autoridade que o
  /// servidor realmente honra (`RoleEnum.name()`: ADMINISTRATOR, RESEARCHER,
  /// CURATOR, USER). É a fonte confiável do cargo do token — ao contrário do
  /// cargo exibido, que o app sincroniza separadamente via `/user/me`.
  ///
  /// Retorna `null` quando não há token ou o `scope` não pôde ser lido.
  Future<UserRole?> getTokenRole() async {
    final token = await getToken();
    if (token == null) return null;

    final scope = _decodeScope(token);
    if (scope == null || scope.isEmpty) return null;

    // O scope pode conter múltiplas autoridades separadas por espaço.
    for (final authority in scope.split(' ')) {
      final role = _mapScopeToRole(authority);
      if (role != null) return role;
    }
    return null;
  }

  /// Decodifica o payload do JWT e devolve o valor do claim `scope`, se existir.
  String? _decodeScope(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final claims = jsonDecode(payload);
      final scope = claims['scope'];
      return scope is String ? scope : null;
    } catch (_) {
      return null;
    }
  }

  /// Mapeia o valor de `RoleEnum.name()` do backend para o [UserRole] do app.
  UserRole? _mapScopeToRole(String authority) {
    switch (authority.toUpperCase()) {
      case 'ADMINISTRATOR':
        return UserRole.administrador;
      case 'RESEARCHER':
        return UserRole.pesquisador;
      case 'CURATOR':
        return UserRole.curador;
      case 'USER':
        return UserRole.comum;
      default:
        return null;
    }
  }

  // Limpa todos os dados (logout)
  Future<void> clearAuthData() async => await _storage.deleteAll();
}
