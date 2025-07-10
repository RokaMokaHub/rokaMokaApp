import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/colors.dart';

class PostQRCodeScreen extends StatefulWidget {
  final String artworkId;

  const PostQRCodeScreen({Key? key, required this.artworkId}) : super(key: key);

  @override
  State<PostQRCodeScreen> createState() => _PostQRCodeScreenState();
}

class _PostQRCodeScreenState extends State<PostQRCodeScreen> {
  Map<String, dynamic>? artworkData;
  bool isLoading = true;
  String? errorMessage;

  final Map<String, Map<String, dynamic>> _mockDatabase = {
    'vangogh-girassois': {
      'title': 'Os Girassóis',
      'author': 'Van Gogh',
      'description':
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis a nisl pretium, fringilla sapien sit amet, finibus sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec ac magna placerat, lobortis erat id, viverra leo. Aliquam leo est, mattis consectetur iaculis a, condimentum ut libero. Integer blandit nisi non diam fringilla ultrices. Fusce ut.',
      'imageUrl':
      'https://guiadoestudante.abril.com.br/wp-content/uploads/sites/4/2023/04/os-girassois-van-gogh.jpg?quality=70&strip=info&w=1280&h=720&crop=1',
      'relatedLinks': [
        'www.loremipsum.com.br',
        'www.loremipsum.com.br',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _fetchArtworkDetails();
  }

  Future<void> _fetchArtworkDetails() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula um atraso de rede
    if (_mockDatabase.containsKey(widget.artworkId)) {
      setState(() {
        artworkData = _mockDatabase[widget.artworkId];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Obra não encontrada.';
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
    const double artworkDetailsCardHeight = 300 + 4 + 24 + 4 + 16; // Aproximadamente 344

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SafeArea(
        child: Column(
          children: [
            // O Stack para a sobreposição do header e do card da obra
            Stack(
              clipBehavior: Clip.none, // Permite que o card da obra saia dos limites do Stack
              children: [
                // O cabeçalho laranja (fundo)
                _OrangeHeader(
                  onBackButtonPressed: () => Navigator.pop(context),
                ),
                // O ArtworkDetailsCard posicionado sobre o cabeçalho
                Positioned(
                  top: 60, // Ajuste para subir ou descer o card completo
                  left: (MediaQuery.of(context).size.width - 220) / 2, // Centraliza
                  child: _ArtworkDetailsCard(
                    imageUrl: artworkData!['imageUrl'],
                    title: artworkData!['title'],
                    author: artworkData!['author'],
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 244), // Ajuste este valor finamente
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.2, // 25% da altura da tela
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          artworkData!['description'],
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Espaçamento entre a descrição e os links
                    _RelatedLinksSection(
                      links: List<String>.from(artworkData!['relatedLinks'] ?? []),
                    ),
                    const SizedBox(height: 24), // Espaço antes do botão
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

class _ArtworkDetailsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  const _ArtworkDetailsCard({Key? key, required this.imageUrl, required this.title, required this.author}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          author,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
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
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Links relacionados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...links.map<Widget>((link) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            link,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        )),
      ],
    );
  }
}

class _CollectStarButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _CollectStarButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 110, vertical: 9),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(primaryColorGradient),
                Color(secondaryColorGradient),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            'Coletar Estrela',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            maxLines: 1, 

          ),
        ),
      ),
    );
  }
}