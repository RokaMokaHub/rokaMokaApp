import 'package:flutter/material.dart';

class PermissionsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const PermissionsScreen({Key? key, required this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: onBack),
          title: Text("Permissões"),
          automaticallyImplyLeading: false,
        ),
        Expanded(child: Center(child: Text("Conteúdo da Tela de Permissões"))),
      ],
    );
  }
}
