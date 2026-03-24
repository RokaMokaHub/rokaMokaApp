import 'package:flutter/material.dart';

class SnackBarNeutro extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const SnackBarNeutro({
    Key? key,
    required this.titulo,
    required this.subtitulo,
  }) : super(key: key);

  SnackBar buildSnackBar(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.fixed,
      content: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.black54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => messenger.hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.black38),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
