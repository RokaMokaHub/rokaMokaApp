import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';

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
      // {'icon': Icons.gps_fixed_sharp, 'label': 'Explorar'}, //retirado no mvp
      {'icon': Icons.qr_code_scanner, 'label': 'Capturar'},
      {'icon': FontAwesomeIcons.box, 'label': 'Coleções'},
      {'icon': FontAwesomeIcons.medal, 'label': 'Emblemas'},
    ];

    if (role == UserRole.comum || role == UserRole.anon) {
      items.add({'icon': FontAwesomeIcons.bell, 'label': 'Solicitar\nCargo'});
    } else {
      items.add({'icon': Icons.more_horiz, 'label': 'Mais'});
    }

    return items;
  }

  void _handleNavigation(int index, BuildContext context, UserRole role) {
    // Último item (índice 4) é o "Mais" ou "Solicitar Cargo"
    if (index == 4) {
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
        case UserRole.anon:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário anônimo não pode solicitar cargo.'),
              duration: Duration(seconds: 2),
            ),
          );
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
    final isAnon = role == UserRole.anon;

    return BottomNavigationBar(
      iconSize: 20,
      currentIndex: currentIndex,
      backgroundColor: Colors.white,
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
      onTap: (index) {
        if (isAnon && index == 5) {
          final snackBar = SnackBarRejeitada(
            titulo: "Usuário anônimo não pode solicitar cargo!",
            subtitulo: "Crie uma conta para solicitar.",
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }

        _handleNavigation(index, context, role);
      },
      items: items.map((item) {
        final isSolicitarCargo = item['label'].toString().contains('Solicitar');
        final isDisabled = isAnon && isSolicitarCargo;

        return BottomNavigationBarItem(
          icon: Icon(
            item['icon'] as IconData,
            color: isDisabled ? Colors.grey : null,
          ),
          label: item['label'] as String,
        );
      }).toList(),
    );
  }
}
