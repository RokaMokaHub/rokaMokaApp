import 'dart:convert';

import '../../constants/webservice.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

//Classe para gerenciar as solicitações de acesso
class ManageRoleRequestService {
  final _authService = AuthService();
  final urlListPermission = Uri.parse(listPermissionsEndPoint);

  /// lista de permissoes
  Future<Map<String, dynamic>> listRequestpermissions() async {
    final token = await _authService.getToken();
    final response = await http.get(
      urlListPermission,
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
          data['exceptionMessage'] ?? 'Erro ao carregar lista de solicitações';
      throw errorMessage;
    }
  }

  //aceita permissoes
  Future<Map<String, dynamic>> acceptPermissions(int permissionId) async {
    final token = await _authService.getToken();
    final urlAcceptPermission = Uri.parse(
      acceptPermissionEndpoint(permissionId),
    );
    final response = await http.post(
      urlAcceptPermission,
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
          data['exceptionMessage'] ?? 'Erro ao aceitar solicitação';
      throw errorMessage;
    }
  }

  //rejeita permissoes
  Future<Map<String, dynamic>> rejectPermissions(
    int permissionId,
    String motivo,
    String userName,
  ) async {
    final token = await _authService.getToken();

    final urlRejectPermission = Uri.parse(
      rejectPermissionEndpoint(permissionId),
    );

    final response = await http.post(
      urlRejectPermission,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'id': permissionId,
        'justificativa': motivo,
        'userName': userName,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      final errorMessage = data['error'] ?? 'Erro ao rejeitar solicitação';
      throw errorMessage;
    }
  }
}
