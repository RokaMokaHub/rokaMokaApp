import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';

/// Tela que exibe os detalhes de uma obra após leitura do QRCode
class PostQRCodeScreen extends StatefulWidget {
  final String artworkId;

  const PostQRCodeScreen({Key? key, required this.artworkId}) : super(key: key);

  @override
  State<PostQRCodeScreen> createState() => _PostQRCodeScreenState();
}

class _PostQRCodeScreenState extends State<PostQRCodeScreen> {
  final AuthService _authService = AuthService();

  Map<String, dynamic>? artworkData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArtworkDetails();
  }

  /// Busca os detalhes da obra pelo ID utilizando token JWT
  Future<Map<String, dynamic>?> fetchArtworkById(String artworkId) async {
    final token = await _authService.getToken();

    if (token == null) {
      print('Usuário não autenticado. Token JWT ausente.');
      return null;
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
        return jsonDecode(response.body);
      } else {
        print('Erro ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e, stack) {
      print('Erro ao buscar obra: $e');
      print(stack);
      return null;
    }
  }

  Future<void> _fetchArtworkDetails() async {
    final response = await fetchArtworkById(widget.artworkId);

    if (response != null && response.containsKey('body')) {
      final Map<String, dynamic> bodyData = response['body'];

      setState(() {
        artworkData = {
          'title': bodyData['nome'] ?? 'Sem título',
          'author': bodyData['nomeArtista'] ?? 'Desconhecido',
          'description': bodyData['descricao'] ?? '',
          'imageUrl': bodyData['image'] ?? '',
          'relatedLinks': [], // Deve ser atualizado quando os links forem incluidos no JSON
        };
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Erro ao buscar obra ou dados inválidos.';
        isLoading = false;
      });
    }
  }

  void _onCollectStar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estrela coletada!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SafeArea(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _OrangeHeader(
                  onBackButtonPressed: () => Navigator.pop(context),
                ),
                Positioned(
                  top: 60,
                  left: (MediaQuery.of(context).size.width - 220) / 2,
                  child: _ArtworkDetailsCard(
                    imageUrl: artworkData!['imageUrl'],
                    title: artworkData!['title'],
                    author: artworkData!['author'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 244),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.2,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          artworkData!['description'],
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RelatedLinksSection(
                      links: List<String>.from(artworkData!['relatedLinks']),
                    ),
                    const SizedBox(height: 24),
                    _CollectStarButton(
                      onPressed: _onCollectStar,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Header com botão de voltar e gradiente laranja
class _OrangeHeader extends StatelessWidget {
  final VoidCallback onBackButtonPressed;

  const _OrangeHeader({Key? key, required this.onBackButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(primaryColorGradient),
            Color(secondaryColorGradient),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: onBackButtonPressed,
        ),
      ),
    );
  }
}

//Card com imagem, título e autor da obra
class _ArtworkDetailsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;

  const _ArtworkDetailsCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    try {
      final decodedBytes = base64Decode(imageUrl);
      imageProvider = MemoryImage(decodedBytes);
    } catch (e) {
      print('Erro ao decodificar imagem: $e');
      imageProvider = const AssetImage('assets/placeholder_image.png');
    }

    return Column(
      children: [
        Container(
          height: 300,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image(
              image: imageProvider,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.broken_image, size: 80, color: Color(greySubtitleColor)),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(titleColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          author,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Color(greySubtitleColor),
          ),
        ),
      ],
    );
  }
}

//Seção de links relacionados
class _RelatedLinksSection extends StatelessWidget {
  final List<String> links;

  const _RelatedLinksSection({Key? key, required this.links}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Links Relacionados:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(primaryColor),
          ),
        ),
        const SizedBox(height: 8),
        ...links.map(
              (link) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              link,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//Botão para coletar estrela
class _CollectStarButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CollectStarButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Coletar Estrela',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
