import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/webservice.dart';

class SignupService {
  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    String deviceId = 'flutter_device_id', // Valor padrão temporário
  }) async {
    final url = Uri.parse(signUpEndpoint);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'password': password,
          'email': email,
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse;
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
