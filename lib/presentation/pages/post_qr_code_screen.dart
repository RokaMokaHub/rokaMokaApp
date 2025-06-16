import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/colors.dart';

class PostQRCodeScreen extends StatefulWidget {
  final String artworkId; // O link ou ID extraído do QR Code

  const PostQRCodeScreen({Key? key, required this.artworkId}) : super(key: key);

  @override
  State<PostQRCodeScreen> createState() => _PostQRCodeScreenState();
}

class _PostQRCodeScreenState extends State<PostQRCodeScreen> {
  Map<String, dynamic>? artworkData;
  bool isLoading = true;
  String? errorMessage;

  // Simulando um banco de dados com um Map
  final Map<String, Map<String, dynamic>> _mockDatabase = {
    'vangogh-girassois': {
      'title': 'Os Girassóis',
      'author': 'Van Gogh',
      'description': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis a nisl pretium, fringilla sapien sit amet, finibus sapien. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec ac magna placerat, lobortis erat id, viverra leo. Aliquam leo est, mattis consectetur iaculis a, condimentum ut libero. Integer blandit nisi non diam fringilla ultrices. Fusce ut.',
      'imageUrl': 'https://guiadoestudante.abril.com.br/wp-content/uploads/sites/4/2023/04/os-girassois-van-gogh.jpg?quality=70&strip=info&w=1280&h=720&crop=1',
      'relatedLinks': [
        'www.loremipsum.com.br',
        'www.loremipsum.com.br',
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    print('PostQRCodeScreen recebeu artworkId: ${widget.artworkId}'); // Adicione esta linha
    _fetchArtworkDetails();
  }

  // Função para simular a busca de dados no "banco de dados"
  Future<void> _fetchArtworkDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Simula um atraso de rede
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Usar o artworkId para buscar os dados
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
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar os detalhes da obra: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Botão de voltar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black, // Cor ajustada para o fundo branco
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(primaryColor)))
                  : errorMessage != null
                  ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (artworkData!['imageUrl'] != null)
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 24.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              artworkData!['imageUrl'],
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  color: Color(greySubtitleColor),
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, color: Colors.grey, size: 80),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    Text(
                      artworkData!['title'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      artworkData!['author'],
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Color(greySubtitleColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      artworkData!['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 24),
                    if (artworkData!['relatedLinks'] != null && artworkData!['relatedLinks'].isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Links relacionados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...artworkData!['relatedLinks'].map<Widget>((link) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              link,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue, // Para simular links
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          )).toList(),
                        ],
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size.fromHeight(50), // Garante que o botão tenha uma largura mínima
                ),
                onPressed: () {
                  // Lógica para "Coletar Estrela"
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Estrela coletada!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Coletar Estrela',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
