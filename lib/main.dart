import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/pages/connect_page_screen.dart';
import 'package:roka_moka_app/presentation/pages/login_screen.dart';
import 'package:roka_moka_app/presentation/pages/signup_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
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
        '/login': (context) => LoginScreen(),
        '/connect': (context) => ConnectScreen(),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
