import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/urgent_alert_dialog.dart';

// ignore: use_key_in_widget_constructors
class ProfileScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Presumi que a Perfil é a página inicial após o login, então currentIndex = 0;
  int currentIndex = 0;
  final authService = AuthService();
  String _appVersion = '';
  String? _firstName;
  String? _lastName;
  String? _userName;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadName();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Versão ${info.version}';
    });
  }

  Future<void> _loadName() async {
    final fetchedFirstName = await authService.getFirstName();
    final fetchedLastName = await authService.getLastName();
    final fetchedUsername = await authService.getUserName();

    setState(() {
      _firstName = fetchedFirstName;
      _lastName = fetchedLastName;
      _userName = fetchedUsername;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 80, bottom: 20),
                          decoration: BoxDecoration(color: Color(0xFFB23F1A)),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 148,
                                  height: 148,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD9D9D9),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'lib/presentation/assets/images/user_icon.png',
                                      ),
                                      fit: BoxFit.none,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (_firstName ?? _userName ?? 'Usuário'),
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _lastName ?? "",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildStack(),
                        _buildListButtons(context),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _appVersion,
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildStack() {
  return Stack(
    children: [
      Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFB23F1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          Container(color: Colors.white, height: 100),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 20,
        children: [
          _buildCards(31, ['rotas', 'completas']),
          _buildCards(120, ['QR', 'Code coletados']),
        ],
      ),
    ],
  );
}

Widget _buildCards(int quantity, List<String> texts) {
  return Container(
    width: 158,
    height: 90,
    decoration: BoxDecoration(
      color: Color(0xFFD9D9D9),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    child: Padding(
      padding: EdgeInsets.all(0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            texts.first,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
          Text(
            texts.last,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildListButtons(BuildContext context) {
  return Padding(
    padding: EdgeInsetsDirectional.only(start: 16, end: 16),
    child: Column(
      spacing: 25,
      children: [
        _buildButton('Editar perfil', context),
        _buildButton('Trocar senha', context),
        _buildButton('Sair', context),
      ],
    ),
  );
}

Widget _buildButton(String descrButton, BuildContext context) {
  return Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFB23F1A), Color(0xFFE94C19)], // Cores do degradê
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25), // Bordas arredondadas
    ),
    child: ElevatedButton(
      onPressed: () async {
        if (descrButton == 'Editar perfil') {
          Navigator.pushNamed(context, editProfileRoute);
        } else if (descrButton == 'Trocar senha') {
          Navigator.pushNamed(context, switchPasswordRoute);
        } else if (descrButton == 'Sair') {
          final shouldLogout = await showDialog<bool>(
            context: context,
            builder:
                (context) => const UrgentAlertDialog(
                  title: 'Tem certeza que deseja sair?',
                  content:
                      'Se esta for uma conta anonima, você perderá o acesso permanentemente.',
                ),
          );

          if (shouldLogout == true) {
            final authService = AuthService();
            authService.clearAuthData();
            Navigator.pushNamedAndRemoveUntil(
              context,
              loginRoute,
              (route) => false,
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: EdgeInsets.zero,
      ),
      child: Text(
        descrButton,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
