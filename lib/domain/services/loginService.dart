import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roka_moka_app/constants/webservice.dart';

class LoginService {
  // Método para realizar login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(loginEndpoint);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Erro ao fazer login: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  // // Método para realizar logout
  // Future<void> logout(String token) async {
  //   final url = Uri.parse('$_baseUrl/logout');
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Erro ao fazer logout: ${response.body}');
  //     }
  //   } catch (e) {
  //     throw Exception('Erro de conexão: $e');
  //   }
  // }

  // // Método para verificar se o usuário está autenticado
  // Future<bool> isAuthenticated(String token) async {
  //   final url = Uri.parse('$_baseUrl/auth/check');
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (e) {
  //     throw Exception('Erro de conexão: $e');
  //   }
  // }
}
