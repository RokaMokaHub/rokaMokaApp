import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

class LoginService {
  final _authService = AuthService();

  Future<void> login(String email, String password) async {
    final url = Uri.parse(loginEndpoint);
    final credentials = base64Encode(utf8.encode('$email:$password'));

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['body']?['jwt'] != null) {
      await _authService.saveToken(data['body']['jwt']);
    } else {
      final errorMessage = data['error'] ?? 'Erro ao fazer login.';
      throw errorMessage;
    }
  }
}
