import 'dart:convert';
import 'dart:io'; // Para HttpHeaders
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';

class ExposureService {
  final AuthService _authService = AuthService();

  /// Cria uma nova exposição.
  /// Retorna o ID da exposição criada se bem-sucedido, caso contrário `null`.
  Future<int?> createExhibition({
    required String name,
    required String description,
    required Map<String, String> enderecoDTO,
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
          'enderecoDTO': enderecoDTO,
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

  /// Busca os detalhes de uma exposição pelo ID utilizando o token JWT para autenticação.
  /// Retorna um [Map<String, dynamic>] contendo os dados da exposição se bem-sucedido.
  Future<Map<String, dynamic>> getExhibitionById(String exhibitionId) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Usuário não autenticado. Token JWT ausente.');
    }

    final url = Uri.parse(getExhibitionByIdEndpoint(exhibitionId));

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('body')) {
          return data['body'];
        } else {
          throw Exception('Resposta da API não contém a chave "body".');
        }
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Erro ${response.statusCode}: ${errorBody['error'] ?? response.body}',
        );
      }
    } catch (e) {
      print('Erro ao buscar exposição: $e');
      rethrow; // Relança a exceção para ser tratada pela UI
    }
  }
}
