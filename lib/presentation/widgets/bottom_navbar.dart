import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  // ignore: use_super_parameters
  BottomNavBar({Key? key, required this.currentIndex, required this.onTap})
    : super(key: key);

  final List<Map<String, dynamic>> items = [
    {'icon': Icons.person_outline_rounded, 'label': 'Perfil'},
    {'icon': Icons.gps_fixed_sharp, 'label': 'Explorar'},
    {'icon': Icons.qr_code_scanner, 'label': 'Capturar'},
    {'icon': FontAwesomeIcons.box, 'label': 'Coleções'},
    {'icon': FontAwesomeIcons.medal, 'label': 'Emblemas'},
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/connect',
          (route) => false,
        ); // Alterar para rota perfil
        break;
      case 1:
        // Navegar para a página de explorar
        break;
      case 2:
        // Navegar para a pagina de capturar
        break;
      case 3:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/collections',
          (route) => false,
        ); // Navegar para a página de Coleções
        break;
      case 4:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/emblems',
          (route) => false,
        ); // Navegar para a pagina de Emblemas
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
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
      type: BottomNavigationBarType.fixed,
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
