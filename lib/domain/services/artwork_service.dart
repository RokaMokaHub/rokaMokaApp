import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';

//Classe responsável por lidar com as operações relacionadas a obras de arte.
class ArtworkService {
  final AuthService _authService = AuthService();

  /// Cria uma obra de arte para uma dada exposição, lidando com upload de arquivos (imagem e QR code).
  /// Retorna `true` se a obra for criada com sucesso.
  Future<bool> createArtworkMultipart({
    required int exhibitionId,
    required String nome,
    required String descricao,
    required String nomeArtista,
    String? link,
    XFile? imagem,
    XFile? qrCode,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final uri = Uri.parse(createArtworkEndpoint(exhibitionId.toString()));
      final request = http.MultipartRequest('POST', uri);
      request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;
      request.fields['nomeArtista'] = nomeArtista;
      request.fields['link'] = link ?? '';

      if (imagem != null) {
        final fileBytes = await imagem.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: imagem.name,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      if (qrCode != null) {
        final qrBytes = await qrCode.readAsBytes();
        // Assumindo que seu backend espera uma string base64 para o QR code
        final qrBase64 = base64Encode(qrBytes);
        request.fields['qrCode'] = qrBase64;
      }

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        throw Exception(
          'Falha ao criar obra: ${errorData['error'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro ao salvar obra: $e');
      rethrow;
    }
  }

  /// Busca os detalhes de uma obra pelo ID utilizando o token JWT para autenticação.
  /// Retorna um [Map<String, dynamic>] contendo os dados da obra se bem-sucedido
  Future<Map<String, dynamic>> fetchArtworkById(String artworkId) async {
    final token = await _authService.getToken();

    if (token == null) {
      throw Exception('Usuário não autenticado. Token JWT ausente.');
    }

    final url = Uri.parse(getArtworkByIdEndpoint(artworkId));

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
      print('Erro ao buscar obra: $e');
      rethrow; // Relança a exceção para ser tratada pela UI
    }
  }
}
