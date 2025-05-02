import 'package:flutter/material.dart';

class CollectionInfoScreen extends StatefulWidget {
  final dynamic id;

  const CollectionInfoScreen({super.key, required this.id});

  @override
  State<CollectionInfoScreen> createState() => _CollectionInfoScreenState();
}

class _CollectionInfoScreenState extends State<CollectionInfoScreen> {
  late int collectedStars;
  final int totalStars = 15;
  bool emblemUnlocked = false;

  @override
  void initState() {
    super.initState();
    collectedStars = 9;
    emblemUnlocked = collectedStars >= totalStars;
  }

  void collectStar() {
    if (collectedStars < totalStars) {
      setState(() {
        collectedStars++;
        if (collectedStars == totalStars) {
          emblemUnlocked = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = "Van Gogh: A Grande Paixão";
    final String museum = "Museu de Arte Leopoldo Gotuzzo";
    final String description =
        "É uma imersão na intensidade emocional de Van Gogh, revelando, por meio de suas obras mais marcantes, a beleza, a angústia e o amor desesperado que moldaram sua arte.";
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/presentation/assets/images/starry_night.jpg',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.28,
            ),
          ),
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                alignment: Alignment.centerLeft,
                width: double.infinity,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context, collectedStars),
                ),
              ),
            ),
          ),
          Positioned(
            top: 230,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Exposição",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD1572A),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        museum,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Estrelas coletadas",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: collectedStars / totalStars,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          color: const Color(0xFFD1572A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "$collectedStars/$totalStars",
                        style: const TextStyle(color: Color(0xFFD1572A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Emblema",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color:
                            emblemUnlocked
                                ? Colors.orange[100]
                                : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        emblemUnlocked ? Icons.emoji_events : Icons.lock,
                        size: 60,
                        color: emblemUnlocked ? Colors.orange : Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: collectStar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Coletar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
