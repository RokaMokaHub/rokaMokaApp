import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roka_moka_app/presentation/pages/permission_screen.dart';
import 'package:roka_moka_app/presentation/pages/profile_screen.dart';
import 'package:roka_moka_app/presentation/pages/collections_screen.dart';
import 'package:roka_moka_app/presentation/pages/emblems_screen.dart';
import 'package:roka_moka_app/presentation/pages/create_exposure_screen.dart';
import 'package:roka_moka_app/presentation/widgets/bottom_navbar.dart';

class HomeController extends StatefulWidget {
  const HomeController({super.key});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController> {
  int _currentIndex = 0;
  int _lastActiveMainIndex = 0;
  Widget? _modalPageContent;
  final ProfileScreen _profileScreen = ProfileScreen();
  final ProfileScreen _explorarScreen = ProfileScreen();
  final ProfileScreen _capturarScreen = ProfileScreen();
  final CollectionsScreen _collectionsScreen = CollectionsScreen();
  final EmblemsScreen _emblemsScreen = EmblemsScreen();
  late final List<Widget> _contentPages;

  late final CreateExposureScreen _createExposureScreenInstance;
  late final PermissionsScreen _permissionsScreenInstance;

  @override
  void initState() {
    super.initState();

    _contentPages = [
      _profileScreen,
      _explorarScreen,
      _capturarScreen,
      _collectionsScreen,
      _emblemsScreen,
    ];

    _createExposureScreenInstance = CreateExposureScreen(
      onBack: _goBackFromModalPage,
    );
    _permissionsScreenInstance = PermissionsScreen(
      onBack: _goBackFromModalPage,
    );
  }

  void _onTapNavItem(int index) {
    setState(() {
      _currentIndex = index;

      if (index < 5) {
        _modalPageContent = null;
        _lastActiveMainIndex = index;
      }
    });
  }

  void _showPageFromModal(Widget page) {
    setState(() {
      _currentIndex = 5;
      _modalPageContent = page;
    });
  }

  void _goBackFromModalPage() {
    setState(() {
      _modalPageContent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (_currentIndex == 5 && _modalPageContent != null) {
      currentPage = _modalPageContent!;
    } else if (_currentIndex == 5 && _modalPageContent == null) {
      currentPage = _contentPages[_lastActiveMainIndex];
    } else {
      currentPage = _contentPages[_currentIndex];
    }

    return Scaffold(
      body: currentPage,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTapNavItem,
        onShowCreateExposure:
            () => _showPageFromModal(_createExposureScreenInstance),
        onShowPermissions: () => _showPageFromModal(_permissionsScreenInstance),
      ),
    );
  }
}
