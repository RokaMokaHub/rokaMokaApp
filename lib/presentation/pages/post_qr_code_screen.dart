import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/snack_bar_rejeitada.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/artwork_service.dart';

/// Tela que exibe os detalhes de uma obra após leitura do QRCode
class PostQRCodeScreen extends StatefulWidget {
  final String qrCode;

  const PostQRCodeScreen({Key? key, required this.qrCode}) : super(key: key);

  @override
  State<PostQRCodeScreen> createState() => _PostQRCodeScreenState();
}

class _PostQRCodeScreenState extends State<PostQRCodeScreen> {
  final ArtworkService _artworkService = ArtworkService();

  Map<String, dynamic>? artworkData;
  bool isLoading = true;
  bool isCollecting = false;
  bool collected = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArtworkDetails();
  }

  Future<void> _fetchArtworkDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final responseBody = await _artworkService.fetchArtworkByQrcode(
        widget.qrCode,
      );

      final rawDescription = (responseBody['descricao'] as String?) ?? '';
      final description = rawDescription.length > 400
          ? '${rawDescription.substring(0, 400)}...'
          : rawDescription;

      setState(() {
        artworkData = {
          'title': responseBody['nome'] ?? 'Sem título',
          'author': responseBody['nomeArtista'] ?? 'Desconhecido',
          'description': description,
          'imageUrl': responseBody['image'] ?? '',
          'link': (responseBody['link'] as String?) ?? '',
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

  Future<void> _onCollectStar() async {
    if (isCollecting || collected) return;
    setState(() => isCollecting = true);

    try {
      final mokadex = await _artworkService.collectStar(widget.qrCode);

      // Extrair nome da exposição da resposta
      String? exhibitionName;
      final collectionSet = mokadex['collectionSet'];
      if (collectionSet is List && collectionSet.isNotEmpty) {
        final exhibition = collectionSet.first['exhibition'];
        if (exhibition is Map) {
          exhibitionName = exhibition['name'] as String?;
        }
      }

      // Verificar se desbloqueou um emblema
      final emblemSet = mokadex['emblemSet'];
      final unlockedEmblem =
          emblemSet is List && emblemSet.isNotEmpty ? emblemSet.first : null;

      if (mounted) {
        setState(() {
          collected = true;
          isCollecting = false;
        });

        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 60),
                const SizedBox(height: 12),
                const Text(
                  'Estrela coletada!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(titleColor),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (exhibitionName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Exposição: $exhibitionName',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(greySubtitleColor),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (unlockedEmblem != null) ...[
                  const SizedBox(height: 16),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
                  const SizedBox(height: 4),
                  Text(
                    'Emblema desbloqueado: ${unlockedEmblem['nome'] ?? ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop(true); // sinaliza coleta ao caller
                },
                child: const Text('Continuar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isCollecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBarRejeitada(
            titulo: 'Erro ao coletar estrela',
            subtitulo: e.toString(),
          ).buildSnackBar(context),
        );
      }
    }
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        _OrangeHeader(
          onBackButtonPressed: () => Navigator.pop(context, false),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: Color(0xFFE94C19),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Obra não encontrada',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(primaryColorGradient),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Não foi possível carregar os detalhes desta obra. Verifique se o QR code está correto ou tente novamente.',
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Color(greySubtitleColor),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _OrangeHeader(
                      onBackButtonPressed: () => Navigator.pop(context, false),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            _ArtworkDetailsCard(
                              imageUrl: artworkData!['imageUrl'],
                              title: artworkData!['title'],
                              author: artworkData!['author'],
                            ),
                            const SizedBox(height: 24),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.2,
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  artworkData!['description'],
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _LinkSection(link: artworkData!['link'] as String),
                            const SizedBox(height: 24),
                            _CollectStarButton(
                              onPressed: _onCollectStar,
                              isCollecting: isCollecting,
                              collected: collected,
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _OrangeHeader extends StatelessWidget {
  final VoidCallback onBackButtonPressed;

  const _OrangeHeader({Key? key, required this.onBackButtonPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      height: 80 + topPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(primaryColorGradient), Color(secondaryColorGradient)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: onBackButtonPressed,
          ),
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
                  child: Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Color(greySubtitleColor),
                  ),
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

class _LinkSection extends StatelessWidget {
  final String link;

  const _LinkSection({Key? key, required this.link}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (link.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mais informações:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(primaryColor),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final uri = Uri.tryParse(link);
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            link,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

class _CollectStarButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isCollecting;
  final bool collected;

  const _CollectStarButton({
    Key? key,
    required this.onPressed,
    required this.isCollecting,
    required this.collected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (isCollecting || collected) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            collected ? Colors.grey : Color(primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: isCollecting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(
              collected ? 'Coletada!' : 'Coletar Estrela',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
