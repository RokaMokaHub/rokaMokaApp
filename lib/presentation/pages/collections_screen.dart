import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/widgets/bottom_navbar.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  _CollectionsScreenState createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  int currentIndex = 3;
  final List<Map<String, dynamic>> colecoes = [
    {
      'titulo': 'Van Gogh: A Grande Paixão',
      'museu': 'Museu de Arte Leopoldo Gotuzzo',
      'progresso': 9,
      'total': 15,
      'completo': false,
    },
    {
      'titulo': 'Frida Kahlo: As Faces de Frida',
      'museu': 'Museu Aurora de Arte Moderna',
      'progresso': 15,
      'total': 22,
      'completo': false,
    },
    {
      'titulo': 'Edward Hopper: O Silêncio de Hopper',
      'museu': 'Museu Metropolitano da Solidão',
      'progresso': 11,
      'total': 11,
      'completo': true,
    },
    {
      'titulo': 'Pablo Picasso: Picasso em Fragmentos',
      'museu': 'Galeria Prisma de Arte',
      'progresso': 15,
      'total': 15,
      'completo': true,
    },
  ];

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            alignment: Alignment.center,
            child: const Text(
              'Coleções',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: colecoes.length,
              itemBuilder: (context, index) {
                final colecao = colecoes[index];
                final double progressoPercentual =
                    colecao['progresso'] / colecao['total'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Color(0xFFB9B9B9)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          colecao['titulo'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE94C19),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Color(0xFFB9B9B9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Container(
                              height: 6,
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.55 *
                                  progressoPercentual,
                              decoration: BoxDecoration(
                                color: Color(0xFFE94C19),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${colecao['progresso']}/${colecao['total']}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                              ],
                            ),
                            Expanded(
                              child: Text(
                                colecao['museu'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                softWrap:
                                    true, // Permite a quebra de linha automática
                                maxLines: null, // Não limita o número de linhas
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ), // Para separar o texto do botão
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colecao['completo'] ? Colors.grey : null,
                                gradient:
                                    colecao['completo']
                                        ? null
                                        : LinearGradient(
                                          colors: [
                                            Color(0xFFB23F1A),
                                            Color(0xFFE94C19),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                colecao['completo'] ? 'Completa' : 'Visualizar',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          BottomNavBar(currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}
