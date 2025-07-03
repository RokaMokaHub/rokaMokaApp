import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';

import '../../constants/routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onShowPermissions;
  final VoidCallback onShowCreateExposure;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onShowPermissions,
    required this.onShowCreateExposure,
  }) : super(key: key);

  List<Map<String, dynamic>> getNavItems(UserRole role) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Perfil'},
      {'icon': Icons.gps_fixed_sharp, 'label': 'Explorar'},
      {'icon': Icons.qr_code_scanner, 'label': 'Capturar'},
      {'icon': FontAwesomeIcons.box, 'label': 'Coleções'},
      {'icon': FontAwesomeIcons.medal, 'label': 'Emblemas'},
    ];

    items.add(
      role == UserRole.comum
          ? {'icon': FontAwesomeIcons.bell, 'label': 'Solicitar\nCargo'}
          : {'icon': Icons.more_horiz, 'label': 'Mais'},
    );

    return items;
  }

  void _handleNavigation(int index, BuildContext context, UserRole role) {
    if (index == 5) {
      switch (role) {
        case UserRole.administrador:
          _showAdminModal(context);
          break;
        case UserRole.curador:
          _showOnlyPermission(context);
          break;
        case UserRole.pesquisador:
          _showOnlyExposure(context);
          break;
        case UserRole.comum:
          Navigator.pushNamed(context, permissionRequestRoute);
          break;
      }
    } else {
      onTap(index);
    }
  }

  void _showAdminModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Permissões'),
            onTap: () {
              Navigator.pop(modalContext);
              onShowPermissions();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Inserir Exposição'),
            onTap: () {
              Navigator.pop(modalContext);
              onShowCreateExposure();
            },
          ),
        ],
      ),
    );
  }

  void _showOnlyPermission(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => ListTile(
        leading: const Icon(Icons.notifications_none),
        title: const Text('Permissões'),
        onTap: () {
          Navigator.pop(modalContext);
          onShowPermissions();
        },
      ),
    );
  }

  void _showOnlyExposure(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => ListTile(
        leading: const Icon(Icons.image_outlined),
        title: const Text('Inserir Exposição'),
        onTap: () {
          Navigator.pop(modalContext);
          onShowCreateExposure();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final items = getNavItems(role);

    return BottomNavigationBar(
      iconSize: 20,
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
      onTap: (index) => _handleNavigation(index, context, role),
      selectedItemColor: const Color(0xFFE94C19),
      unselectedItemColor: const Color(0xFF555555),
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item['icon'] as IconData),
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}
