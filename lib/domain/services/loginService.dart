import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roka_moka_app/constants/webservice.dart';

class LoginService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(loginEndpoint);
    final credentials = base64Encode(utf8.encode('$email:$password'));

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
