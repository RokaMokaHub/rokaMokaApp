import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/widgets/bottom_navbar.dart';

class EmblemsScreen extends StatefulWidget {
  const EmblemsScreen({Key? key}) : super(key: key);

  @override
  _EmblemsScreenState createState() => _EmblemsScreenState();
}

class _EmblemsScreenState extends State<EmblemsScreen> {
  List<Map<String, String>> emblemas = [];
  int currentIndex = 4;

  @override
  void initState() {
    super.initState();
    // Inicializando a lista de emblemas
    emblemas = List.generate(
      20,
      (index) => {
        'nome': index == 0 ? 'Edward Hopper' : 'Nome da emblema $index',
        'imagem': index == 0 ? 'assets/edward_hopper.png' : '',
      },
    );
  }

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
              'Emblemas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: emblemas.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final emblema = emblemas[index];
                  final hasImage = emblema['imagem']!.isNotEmpty;

                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            hasImage ? AssetImage(emblema['imagem']!) : null,
                        child:
                            !hasImage
                                ? const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        emblema['nome']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          BottomNavBar(currentIndex: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}
