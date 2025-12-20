import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

//Classe responsavel pela criacao de usuario via banco de dados
class UserService {
  final _authService = AuthService();

  // Criando user
  Future<Map<String, dynamic>> createUser(
    String email,
    String password,
    String name,
    String firstName,
    String lastName,
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
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['body']['jwt'];
      await _authService.saveAuthData(
        token: token,
        email: email,
        userName: name,
        deviceId: deviceId,
        firstName: firstName,
        lastName: lastName,
        password: password,
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
    String oldPassword,
    String newPassword,
    String name,
  ) async {
    final url = Uri.parse(resetPasswordEndpoint);
    final token = await _authService.getToken();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'name': name,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage = data['error'] ?? data['exceptionMessage'];
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
      body: jsonEncode({'userName': userName, 'deviceId': deviceId}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['body']['jwt'];
      await _authService.saveAuthDataAnon(
        token: token,
        userName: userName,
        deviceId: deviceId,
      );
      return data;
    } else {
      final errorMessage =
          data['exceptionMessage'] ?? 'Erro ao criar usuário anônimo.';
      throw errorMessage;
    }
  }

  //recupera informacoes do usuario
  Future<Map<String, dynamic>> getUserInfo() async {
    final token = await _authService.getToken();
    final url = Uri.parse(getUserInfoEndpoint);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage =
          data['error'] ?? 'Erro ao obter informações do usuário.';
      throw errorMessage;
    }
  }

  //envia email para recuperar senha
  Future<Map<String, dynamic>> sendEmailForgotPassword(String email) async {
    final url = Uri.parse(sendEmailForgotPasswordEndpoint(email));

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage = data['error'] ?? 'Erro ao enviar email.';
      throw errorMessage;
    }
  }

  // Obter ID do dispositivo
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'ios-unknown';
    }

    return 'unsupported-platform';
  }
}
