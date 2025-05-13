import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/presentation/pages/collection_info_screen.dart';
import 'package:roka_moka_app/presentation/pages/collections_screen.dart';
import 'dart:io';

import 'package:roka_moka_app/presentation/pages/qr_code_screen.dart';
import 'package:roka_moka_app/presentation/pages/connect_page_screen.dart';
import 'package:roka_moka_app/presentation/pages/emblems_screen.dart';
import 'package:roka_moka_app/presentation/pages/login_screen.dart';
import 'package:roka_moka_app/presentation/pages/profile_screen.dart';
import 'package:roka_moka_app/presentation/pages/signup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final deviceInfoPlugin = DeviceInfoPlugin();

  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      if (kDebugMode) {
        print('Device ID (Android ID): ${androidInfo.id}');
      }
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      if (kDebugMode) {
        print(
          'Device ID (identifierForVendor): ${iosInfo.identifierForVendor}',
        );
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao obter Device ID: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen(),
      routes: {
        loginRoute: (context) => LoginScreen(),
        connectRoute: (context) => ConnectScreen(),
        signupRoute: (context) => QRCodeScreen(),
        profileRoute: (context) => ProfileScreen(),
        emblemsRoute: (context) => EmblemsScreen(),
        collectionsRoute: (context) => CollectionsScreen(),
        collectionInfoRoute: (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          return CollectionInfoScreen(id: args);
        },
      },
    );
  }
}
