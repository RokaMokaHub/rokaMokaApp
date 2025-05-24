import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  List<Map<String, dynamic>> getNavItems(UserRole role) {
    final items = [
      {'icon': Icons.person_outline_rounded, 'label': 'Perfil'},
      {'icon': Icons.gps_fixed_sharp, 'label': 'Explorar'},
      {'icon': Icons.qr_code_scanner, 'label': 'Capturar'},
      {'icon': FontAwesomeIcons.box, 'label': 'Coleções'},
      {'icon': FontAwesomeIcons.medal, 'label': 'Emblemas'},
    ];

    if (role == UserRole.comum) {
      items.add({
        'icon': Icons.assignment_ind_outlined,
        'label': 'Solicitar Cargo',
      });
    } else {
      items.add({'icon': Icons.more_horiz, 'label': 'Mais'});
    }

    return items;
  }

  void _handleNavigation(int index, BuildContext context, UserRole role) {
    if (index != 5) {
      onTap(index);
    } else {
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
          Navigator.pushNamed(context, '/solicitar_cargo');
          break;
      }
    }
  }

  void _showAdminModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_none),
                title: const Text('Permissões'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/permissions');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Inserir Exposição'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/insert_exhibition');
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
      builder:
          (context) => ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Permissões'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/permissions');
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
      builder:
          (context) => ListTile(
            leading: const Icon(Icons.image_outlined),
            title: const Text('Inserir Exposição'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, createExposureRoute);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final items = getNavItems(role);

    return BottomNavigationBar(
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
      items:
          items.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item['icon']),
              label: item['label'],
            );
          }).toList(),
    );
  }
}
