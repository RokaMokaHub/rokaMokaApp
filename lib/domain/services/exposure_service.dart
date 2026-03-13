import 'dart:convert';
import 'dart:io'; // Para HttpHeaders
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';

// Classe para lidar com os serviços de exposição
class ExposureService {
  final AuthService _authService = AuthService();

  /// Cria uma nova exposição.
  /// Retorna o ID da exposição criada se bem-sucedido, caso contrário `null`.
  Future<int?> createExhibition({
    required String name,
    required String description,
    required int locationId,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final response = await http.post(
        Uri.parse(createExhibitionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'locationId': locationId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['body']['id'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Falha ao criar exposição: ${errorData['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro ao criar exposição: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> listExhibitions() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(listExhibitionsEndpoint),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final body = data['body'];
      if (body is List) {
        return body.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else {
      throw Exception('Falha ao listar exposições: ${response.statusCode}');
    }
  }

  Future<void> updateExhibition({
    required int id,
    required String name,
    String? description,
    required int locationId,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.patch(
      Uri.parse(updateExhibitionEndpoint),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode({
        'id': id,
        'name': name,
        'description': description ?? '',
        'locationId': locationId,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        'Erro ao atualizar exposição: ${errorData['error'] ?? response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> getExhibitionById(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(getExhibitionByIdEndpoint(id.toString())),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['body'] as Map<String, dynamic>;
    } else {
      throw Exception('Falha ao buscar exposição: ${response.statusCode}');
    }
  }
}
