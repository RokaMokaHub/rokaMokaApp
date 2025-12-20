import 'dart:convert';

import '../../constants/webservice.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

//Classe utilizada para solicitar acesso como pesquisador ou curador ou verificar status
class RequestRoleService {
  final _authService = AuthService();
  final urlResearcher = Uri.parse(requestAccessResearcherEndpoint);
  final urlCurator = Uri.parse(requestAccessCuratorEndpoint);

  /// Solicita acesso como pesquisador.
  Future<Map<String, dynamic>> requestAccessAsResearcher() async {
    final name = await _authService.getUserName();
    final password = await _authService.getPassword();
    final credentials = base64Encode(utf8.encode('$name:$password'));
    final response = await http.post(
      urlResearcher,
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
          data['exceptionMessage'] ?? 'Erro ao solicitar acesso.';
      throw errorMessage;
    }
  }

  /// Solicita acesso como curador
  Future<Map<String, dynamic>> requestAccessAsCurator() async {
    final name = await _authService.getUserName();
    final password = await _authService.getPassword();
    final credentials = base64Encode(utf8.encode('$name:$password'));
    final response = await http.post(
      urlCurator,
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
          data['exceptionMessage'] ?? 'Erro ao solicitar acesso.';
      throw errorMessage;
    }
  }

  /// Verifica o status da permissao
  Future<Map<String, dynamic>> checkPermissionStatus() async {
    final token = await _authService.getToken();
    final url = Uri.parse(statusRequestAccessEndpoint);

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
          data['exceptionMessage'] ?? 'Erro ao verificar status da permissão.';
      throw errorMessage;
    }
  }
}
