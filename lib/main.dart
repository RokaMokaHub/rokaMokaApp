import 'package:flutter/material.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/connect_page.dart';
import 'presentation/pages/signup_page.dart';

void main() {
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
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/connect': (context) => ConnectPage(),
        '/signup': (context) => SignupPage(),
      },
    );
  }
}
