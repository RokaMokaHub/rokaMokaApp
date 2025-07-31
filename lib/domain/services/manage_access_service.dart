import 'dart:convert';

import '../../constants/webservice.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

class ManageAccessService {
  final _authService = AuthService();
  final urlListPermission = Uri.parse(listPermissionsEndPoint);

  /// lista de permissoes
  Future<Map<String, dynamic>> listRequestpermissions() async {
    final name = await _authService.getName();
    final password = await _authService.getPassword();
    final credentials = base64Encode(utf8.encode('$name:$password'));
    final response = await http.get(
      urlListPermission,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic $credentials',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage =
          data['exceptionMessage'] ?? 'Erro ao carregar lista de solicitações';
      throw errorMessage;
    }
  }
}
