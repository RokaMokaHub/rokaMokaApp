import 'package:flutter/material.dart';

class SnackBarAceita extends StatelessWidget {
  final String? nome;
  final String titulo;
  final String subtitulo;

  const SnackBarAceita({
    Key? key,
    this.nome,
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
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFFCBF7C4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.black87),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => messenger.hideCurrentSnackBar(),
              child: Icon(Icons.close, color: Colors.black54),
            ),
          ],
        ),
      ),
      duration: Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
