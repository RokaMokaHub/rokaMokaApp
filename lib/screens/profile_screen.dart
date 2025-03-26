import 'package:flutter/material.dart';
import 'package:roka_moka_app/widgets/bottom_navbar.dart';

// ignore: use_key_in_widget_constructors
class ProfileScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Presumi que a Perfil é a página inicial após o login, então currentIndex = 0;
  int currentIndex = 0;

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 80, bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFFB23F1A),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD9D9D9),
                        border: Border.all(color: Colors.white, width: 2),
                        image: DecorationImage(
                          image: AssetImage('./assets/images/user_icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Text(
                      'XingLing Sakuma',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildStack(),
            _buildListButtons(),
            Expanded(child: Container(color: Colors.white)),
            BottomNavBar(currentIndex: currentIndex, onTap: onTap),
          ],
        ),
      ),
      backgroundColor: Colors.white,
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
          Container(color: Colors.white, height: 60),
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
    height: 80,
    decoration: BoxDecoration(
      color: Color(0xFFD9D9D9),
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          quantity.toString(),
          style: TextStyle(
            fontSize: 24,
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
  );
}

Widget _buildListButtons() {
  return Padding(
    padding: EdgeInsetsDirectional.only(start: 16, end: 16),
    child: Column(
      spacing: 25,
      children: [
        _buildButton('Editar perfil'),
        _buildButton('Ajuda'),
        _buildButton('Sair'),
      ],
    ),
  );
}

Widget _buildButton(String descrButton) {
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
      onPressed: () => debugPrint('Clicou em $descrButton'),
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
