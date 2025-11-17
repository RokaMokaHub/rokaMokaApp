import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';
import 'package:roka_moka_app/presentation/controllers/home_controller.dart';
import 'package:roka_moka_app/presentation/pages/collection_info_screen.dart';
import 'package:roka_moka_app/presentation/pages/collections_screen.dart';
import 'package:roka_moka_app/presentation/pages/explorer_screen.dart';
import 'package:roka_moka_app/presentation/pages/permission_request_screen.dart';
import 'package:roka_moka_app/presentation/pages/permission_screen.dart';
import 'package:roka_moka_app/presentation/pages/post_qr_code_screen.dart';
import 'dart:io';

import 'package:roka_moka_app/presentation/pages/qr_code_screen.dart';
import 'package:roka_moka_app/presentation/pages/connect_page_screen.dart';
import 'package:roka_moka_app/presentation/pages/create_exposure_screen.dart';
import 'package:roka_moka_app/presentation/pages/edit_profile_screen.dart';
import 'package:roka_moka_app/presentation/pages/emblems_screen.dart';
import 'package:roka_moka_app/presentation/pages/login_screen.dart';
import 'package:roka_moka_app/presentation/pages/profile_screen.dart';
import 'package:roka_moka_app/presentation/pages/signup_screen.dart';

import 'domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );

  final authService = AuthService();
  final loggedIn = await authService.isLoggedIn();
  final userProvider = UserProvider();
  await userProvider.loadRole();
  final userService = UserService();


  if (loggedIn) {
    try {
      final userInfo = await userService.getUserInfo();
      final role = userInfo['role'] ?? 'comum';
      await userProvider.setRole(role);
    } catch (e) {
      if (kDebugMode) print('Erro ao sincronizar usuário: $e');
    }
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ChangeNotifierProvider.value(
      value: userProvider,
      child: MyApp(loggedIn: loggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roká Móka',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: loggedIn ? HomeController() : LoginScreen(),
      routes: {
        loginRoute: (context) => LoginScreen(),
        editProfileRoute: (context) => EditProfileScreen(),
        connectRoute: (context) => ConnectScreen(),
        signupRoute: (context) => SignupScreen(),
        profileRoute: (context) => ProfileScreen(),
        emblemsRoute: (context) => EmblemsScreen(),
        collectionsRoute: (context) => CollectionsScreen(),
        qrCodeRoute: (context) => QRCodeScreen(),
        explorerRoute: (context) => ExplorerScreen(),
        permissionRequestRoute: (context) {
          return SolicitarPermissaoScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
        collectionInfoRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return CollectionInfoScreen(id: args);
        },
        createExposureRoute:
            (context) => CreateExposureScreen(
              onBack: () {
                Navigator.of(context).pop();
              },
            ),
        permissionsRoute: (context) {
          return PermissionsScreen(
            onBack: () {
              Navigator.of(context).pop();
            },
          );
        },
      },
    );
  }
}
