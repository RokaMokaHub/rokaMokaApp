import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';
import 'package:roka_moka_app/presentation/controllers/home_controller.dart';
import 'package:roka_moka_app/presentation/pages/collection_info_screen.dart';
import 'package:roka_moka_app/presentation/pages/collections_screen.dart';
import 'package:roka_moka_app/presentation/pages/explorer_screen.dart';
import 'package:roka_moka_app/presentation/pages/forgot_password_screen.dart';
import 'package:roka_moka_app/presentation/pages/send_email_forgot_password_screen.dart';
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
import 'package:roka_moka_app/presentation/pages/switch_password_screen.dart';

import 'domain/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final authService = AuthService();
  final loggedIn = await authService.isLoggedIn();

  final userProvider = UserProvider();
  await userProvider.loadRole();

  if (loggedIn) {
    try {
      final userService = UserService();
      final userInfo = await userService.getUserInfo();
      final role = userInfo['role'] ?? 'comum';
      await userProvider.setRole(role);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao sincronizar usuário: $e');
      }
    }
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder:
          (_) => ChangeNotifierProvider.value(
            value: userProvider,
            child: MyApp(loggedIn: loggedIn),
          ),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAppLinks();
    });
  }

  Future<void> _initAppLinks() async {
    final Uri? initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    if (uri.host == 'app.dominio.com' && uri.path == '/auth/reset') {
      final token = uri.queryParameters['token'];

      if (token != null) {
        navigatorKey.currentState?.pushNamed(
          forgotPasswordRoute,
          arguments: token,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Roká Móka',

      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: widget.loggedIn ? HomeController() : LoginScreen(),

      routes: {
        loginRoute: (_) => LoginScreen(),
        editProfileRoute: (_) => EditProfileScreen(),
        connectRoute: (_) => ConnectScreen(),
        signupRoute: (_) => SignupScreen(),
        profileRoute: (_) => ProfileScreen(),
        emblemsRoute: (_) => EmblemsScreen(),
        collectionsRoute: (_) => CollectionsScreen(),
        qrCodeRoute: (_) => QRCodeScreen(),
        explorerRoute: (_) => ExplorerScreen(),
        switchPasswordRoute: (_) => SwitchPasswordScreen(),
        sendEmailForgotPasswordRoute: (_) => SendEmailForgotPasswordScreen(),

        forgotPasswordRoute: (context) {
          final token = ModalRoute.of(context)!.settings.arguments as String?;
          return ForgotPasswordScreen(token: token);
        },

        permissionRequestRoute:
            (_) => SolicitarPermissaoScreen(
              onBack: () => navigatorKey.currentState?.pop(),
            ),

        collectionInfoRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return CollectionInfoScreen(id: args);
        },

        createExposureRoute:
            (_) => CreateExposureScreen(
              onBack: () => navigatorKey.currentState?.pop(),
            ),

        permissionsRoute:
            (_) => PermissionsScreen(
              onBack: () => navigatorKey.currentState?.pop(),
            ),
      },
    );
  }
}
