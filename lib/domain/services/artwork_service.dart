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
    String? qrCode,
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

      if (qrCode != null && qrCode.isNotEmpty) {
        request.fields['qrCode'] = qrCode;
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

  Future<void> updateArtwork({
    required int id,
    required String nome,
    String? nomeArtista,
    String? descricao,
    String? link,
    String? qrCode,
    XFile? imagem,
  }) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final uri = Uri.parse(updateArtworkEndpoint);
    final request = http.MultipartRequest('PATCH', uri);
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    request.fields['id'] = id.toString();
    request.fields['nome'] = nome;
    if (nomeArtista != null) request.fields['nomeArtista'] = nomeArtista;
    if (descricao != null) request.fields['descricao'] = descricao;
    if (link != null) request.fields['link'] = link;
    if (qrCode != null && qrCode.isNotEmpty) request.fields['qrCode'] = qrCode;

    if (imagem != null) {
      final fileBytes = await imagem.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: imagem.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamed = await request.send();
    if (streamed.statusCode != 200) {
      final body = await streamed.stream.bytesToString();
      final errorData = jsonDecode(body);
      throw Exception(
        'Erro ao atualizar obra: ${errorData['error'] ?? streamed.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> listArtworksByExhibition(
    int exhibitionId,
  ) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(listArtworksByExhibitionEndpoint(exhibitionId.toString())),
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
      throw Exception('Falha ao listar obras: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getMissingArtworks(
    int exhibitionId,
  ) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(getMissingArtworksEndpoint(exhibitionId.toString())),
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
      throw Exception(
        'Falha ao buscar obras não coletadas: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>> fetchArtworkByQrcode(String qrcode) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.get(
      Uri.parse(getArtworkByQrcodeEndpoint(qrcode)),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['body'] as Map<String, dynamic>;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Obra não encontrada para este QR code: ${errorBody['exceptionMessage'] ?? response.statusCode}',
      );
    }
  }

  /// Coleta uma estrela via QR code. Retorna o MokadexOutputDTO (body).
  Future<Map<String, dynamic>> collectStar(String qrcode) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.post(
      Uri.parse(collectStarEndpoint(qrcode)),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['body'] as Map<String, dynamic>;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Erro ao coletar estrela: ${errorBody['exceptionMessage'] ?? response.statusCode}',
      );
    }
  }

  Future<void> deleteArtwork(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token de autenticação não encontrado.');

    final response = await http.delete(
      Uri.parse(deleteArtworkEndpoint(id.toString())),
      headers: {
        'Content-Type': 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(
        'Erro ao deletar obra: ${errorData['error'] ?? response.statusCode}',
      );
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
