import 'package:flutter/material.dart';

class ExplorerScreen extends StatelessWidget {
  const ExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'lib/presentation/assets/images/explore_image.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.9)),
          Center(
            child: Text(
              'Em breve!',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
