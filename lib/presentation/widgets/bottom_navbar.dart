import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // ignore: use_super_parameters
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final List<Map<String, dynamic>> items = const [
    {'icon': Icons.person_outline_rounded, 'label': 'Perfil'},
    {'icon': Icons.qr_code_scanner, 'label': 'Capturar'},
    {'icon': Icons.collections, 'label': 'Coleções'},
  ];

  void _handleNavigation(int index, BuildContext context) {
    onTap(index);

    // Verificação para impedir que navegue para a página que o usuário já tá
    if (index == currentIndex) {
      debugPrint("Já estamos na página $index, não precisa navegar.");
      return;
    }

    switch (index) {
      case 0:
        // Navegar para a página de Perfil
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Alterar para rota perfil
        break;
      case 1:
        // Navegar para a página de Capturas
        break;
      case 2:
        // Navegar para a página de Coleções
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleNavigation(index, context),
      selectedItemColor: Color(0xFFE94C19),
      unselectedItemColor: Color(0xFF555555),
      selectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE94C19),
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Color(0xFF555555),
      ),
      items:
          items.map<BottomNavigationBarItem>((item) {
            return BottomNavigationBarItem(
              icon: Icon(item['icon']),
              label: item['label'],
            );
          }).toList(),
    );
  }
}
