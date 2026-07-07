import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';

/// Lançada quando o usuário tenta acessar um emblema que ainda não conquistou
/// (backend responde 403). Usada para exibir o bloqueio de visualização das obras.
class EmblemForbiddenException implements Exception {
  final String message;
  EmblemForbiddenException(this.message);

  @override
  String toString() => message;
}

class EmblemService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> createEmblem({
    required int exhibitionId,
    String? nome,
    String? descricao,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.post(
      Uri.parse(createEmblemEndpoint),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'exhibitionId': exhibitionId,
        if (nome != null && nome.isNotEmpty) 'nome': nome,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['body'] as Map<String, dynamic>;
    } else {
      throw Exception(
        data['exceptionMessage'] ??
            data['error'] ??
            'Erro ${response.statusCode} ao criar emblema.',
      );
    }
  }

  Future<Map<String, dynamic>> getEmblemById(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(getEmblemByIdEndpoint(id.toString())),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['body'] as Map<String, dynamic>;
    } else if (response.statusCode == 403) {
      throw EmblemForbiddenException(
        data['exceptionMessage'] ?? 'Você ainda não conquistou este emblema.',
      );
    } else {
      throw Exception(
        data['exceptionMessage'] ??
            data['error'] ??
            'Erro ${response.statusCode} ao buscar emblema.',
      );
    }
  }

  Future<void> deleteEmblem(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.delete(
      Uri.parse(deleteEmblemEndpoint(id.toString())),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(
        data['exceptionMessage'] ??
            data['error'] ??
            'Erro ${response.statusCode} ao deletar emblema.',
      );
    }
  }
}
