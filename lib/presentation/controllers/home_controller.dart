import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/pages/permission_screen.dart';
import 'package:roka_moka_app/presentation/pages/profile_screen.dart';
import 'package:roka_moka_app/presentation/pages/collections_screen.dart';
import 'package:roka_moka_app/presentation/pages/emblems_screen.dart';
import 'package:roka_moka_app/presentation/pages/create_exposure_screen.dart';
import 'package:roka_moka_app/presentation/pages/edit_exposure_screen.dart';
import 'package:roka_moka_app/presentation/pages/locations_screen.dart';
import 'package:roka_moka_app/presentation/pages/qr_code_screen.dart';
import 'package:roka_moka_app/presentation/widgets/bottom_navbar.dart';

//Classe principal do aplicativo usada para gerenciar telas, roles e outras funcionalidades.
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
  // final ExplorerScreen _explorarScreen = ExplorerScreen();
  final CollectionsScreen _collectionsScreen = CollectionsScreen();
  final EmblemsScreen _emblemsScreen = EmblemsScreen();
  late final List<Widget> _contentPages;

  late final CreateExposureScreen _createExposureScreenInstance;
  late final EditExposureScreen _editExposureScreenInstance;
  late final PermissionsScreen _permissionsScreenInstance;
  late final LocationsScreen _locationsScreenInstance;
  late final QRCodeScreen _capturarScreen;

  @override
  void initState() {
    super.initState();

    _capturarScreen = QRCodeScreen(onBack: () => _onTapNavItem(0));

    _contentPages = [
      _profileScreen,
      // _explorarScreen,
      _capturarScreen,
      _collectionsScreen,
      _emblemsScreen,
    ];

    _createExposureScreenInstance = CreateExposureScreen(
      onBack: _goBackFromModalPage,
      onConfirmed: _goBackToCollections,
    );

    _editExposureScreenInstance = EditExposureScreen(
      onBack: _goBackFromModalPage,
    );

    _permissionsScreenInstance = PermissionsScreen(
      onBack: _goBackFromModalPage,
    );

    _locationsScreenInstance = LocationsScreen(onBack: _goBackFromModalPage);
  }

  void _onTapNavItem(int index) {
    setState(() {
      _currentIndex = index;

      if (index < 4) {
        // apenas as 4 telas principais
        _modalPageContent = null;
        _lastActiveMainIndex = index;
      }
    });
  }

  void _showPageFromModal(Widget page) {
    setState(() {
      _currentIndex = 4; // corresponde ao botão "Mais"
      _modalPageContent = page;
    });
  }

  void _goBackFromModalPage() {
    setState(() {
      _modalPageContent = null;
    });
  }

  void _goBackToCollections() {
    setState(() {
      _modalPageContent = null;
      _currentIndex = 2;
      _lastActiveMainIndex = 2;
      _contentPages[2] = CollectionsScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    if (_currentIndex == 4 && _modalPageContent != null) {
      currentPage = _modalPageContent!;
    } else if (_currentIndex == 4 && _modalPageContent == null) {
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
        onShowEditExposure:
            () => _showPageFromModal(_editExposureScreenInstance),
        onShowPermissions: () => _showPageFromModal(_permissionsScreenInstance),
        onShowLocations: () => _showPageFromModal(_locationsScreenInstance),
      ),
    );
  }
}
