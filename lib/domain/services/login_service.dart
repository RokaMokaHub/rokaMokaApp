import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

class LoginService {
  final AuthService _authService = AuthService();

  Future<void> login(String nome, String password) async {
    final url = Uri.parse(loginEndpoint);
    final credentials = base64Encode(utf8.encode('$nome:$password'));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['body']?['jwt'] != null) {
      final token = data['body']['jwt'];

      // Armazena dados no AuthService
      await _authService.saveAuthData(
        token: token,
        email: nome,
        name: nome,
      );
    } else {
      final errorMessage = data['error'] ?? 'Erro ao fazer login.';
      throw errorMessage;
    }
  }
}
