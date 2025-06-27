import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';
import 'package:roka_moka_app/constants/webservice.dart';

class UserService {
  final _authService = AuthService();

  Future<void> resetPassword(
    String email,
    String password,
    String name,
    String deviceId,
  ) async {
    final url = Uri.parse(resetPasswordEndpoint);
    final credentials = base64Encode(utf8.encode(AuthService().getToken() as String));

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['error'] ?? 'Erro ao fazer login.';
        throw errorMessage;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
