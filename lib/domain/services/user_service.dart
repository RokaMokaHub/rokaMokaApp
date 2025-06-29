import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

class UserService {
  final _authService = AuthService();

  //Criando user
  Future<Map<String, dynamic>> createUser(
    String email,
    String password,
    String name,
    String deviceId,
  ) async {
    final url = Uri.parse(createUserEndpoint);
    final token = _authService.getToken();
    final credentials = base64Encode(utf8.encode(token as String));

    try {
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['error'] ?? 'Erro ao criar usuário.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Falha na requisição: $e');
    }
  }

  //Resetando senha
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String name,
    String deviceId,
  ) async {
    final url = Uri.parse(resetPasswordEndpoint);
    final token = _authService.getToken();
    final credentials = base64Encode(utf8.encode(token as String));

    try {
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

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['error'] ?? 'Erro ao resetar senha.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Falha na requisição: $e');
    }
  }

  //CRIANDO USER ANONIMO
  Future<Map<String, dynamic>> createAnonymousUser(
    String userName,
    String deviceId,
  ) async {
    final url = Uri.parse(createAnonUserEndpoint);
    final token = _authService.getToken();
    final credentials = base64Encode(utf8.encode(token as String));

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
        body: jsonEncode({'userName': userName, 'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['error'] ?? 'Erro ao criar usuário anônimo.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Falha na requisição: $e');
    }
  }
}
