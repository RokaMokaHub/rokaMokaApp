import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

class UserService {
  final _authService = AuthService();

  // Criando user
  Future<Map<String, dynamic>> createUser(
      String email,
      String password,
      String name,
      ) async {
    final deviceId = await getDeviceId();
    final url = Uri.parse(createUserEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'deviceId': deviceId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['body']['jwt'];
      await _authService.saveAuthData(
        token: token,
        email: email,
        name: name,
        deviceId: deviceId,
      );
      return data;
    } else {
      final errorMessage =
          data['exceptionMessage'] ?? 'Erro desconhecido ao criar o usuário.';
      throw errorMessage;
    }
  }

  // Resetando senha
  Future<Map<String, dynamic>> resetPassword(
      String email,
      String password,
      String name,
      ) async {
    final deviceId = await getDeviceId();
    final url = Uri.parse(resetPasswordEndpoint);
    final token = await _authService.getToken();
    final credentials = base64Encode(utf8.encode(token as String));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'deviceId': deviceId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage = data['error'] ?? 'Erro ao resetar senha.';
      throw errorMessage;
    }
  }

  // Criando usuário anônimo
  Future<Map<String, dynamic>> createAnonymousUser(String userName) async {
    final deviceId = await getDeviceId();
    final url = Uri.parse(createAnonUserEndpoint);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': userName,
        'deviceId': deviceId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['body']['jwt'];
      await _authService.saveAuthDataAnon(
        token: token,
        name: userName,
        deviceId: deviceId,
      );
      return data;
    } else {
      final errorMessage =
          data['error'] ?? 'Erro ao criar usuário anônimo.';
      throw errorMessage;
    }
  }

  // Obter ID do dispositivo
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id ?? 'android-unknown';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios-unknown';
    }

    return 'unsupported-platform';
  }
}
