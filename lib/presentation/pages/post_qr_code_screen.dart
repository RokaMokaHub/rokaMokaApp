import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart'; // Importe o ArtworkService unificado

/// Tela que exibe os detalhes de uma obra após leitura do QRCode
class PostQRCodeScreen extends StatefulWidget {
  final String artworkId;

  const PostQRCodeScreen({Key? key, required this.artworkId}) : super(key: key);

  @override
  State<PostQRCodeScreen> createState() => _PostQRCodeScreenState();
}

class _PostQRCodeScreenState extends State<PostQRCodeScreen> {
  // Instância do ArtworkService unificado
  final ArtworkService _artworkService = ArtworkService();

  Map<String, dynamic>? artworkData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArtworkDetails();
  }

  /// Busca os detalhes da obra utilizando o ArtworkService
  Future<void> _fetchArtworkDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final responseBody = await _artworkService.fetchArtworkById(widget.artworkId); // Chamando a função do serviço unificado

      setState(() {
        artworkData = {
          'title': responseBody['nome'] ?? 'Sem título',
          'author': responseBody['nomeArtista'] ?? 'Desconhecido',
          'description': responseBody['descricao'] ?? '',
          'imageUrl': responseBody['image'] ?? '',
          'relatedLinks': responseBody['links'] != null && responseBody['links'] is List
              ? List<String>.from(responseBody['links'])
              : [],
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar os detalhes da obra: ${e.toString()}';
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

class _OrangeHeader extends StatelessWidget {
  final VoidCallback onBackButtonPressed;

  const _OrangeHeader({Key? key, required this.onBackButtonPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
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
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Color(greySubtitleColor),
          ),
        ),
      ],
    );
  }
}

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