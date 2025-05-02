import 'package:flutter/material.dart';
import 'package:roka_moka_app/presentation/widgets/password_text_field.dart';

// ignore: use_key_in_widget_constructors
class EditProfileScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfileScreen> {
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();

    _userNameController = TextEditingController(text: 'XingLing Sakuma');
    _emailController = TextEditingController(text: 'xingling@email.com');
    _passwordController = TextEditingController(text: '123456');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

    Widget _buttonSave() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _submitted = true;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Salvar',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _appBar(context),
            _buildStack(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    'Editar perfil',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.left,
                  ),
                  _textField('Nome Completo', _userNameController),
                  _textField('Email', _emailController),
                  PasswordTextField(
                    controller: _passwordController,
                    placeholder: 'Senha',
                    submitted: _submitted,
                  ),
                  _buttonSave(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _textField(String placeholder, TextEditingController textController) {
  return TextField(
    controller: textController,
    enabled: false,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      hintText: placeholder,
      hintStyle: TextStyle(color: Color(0xFFABABAB)),
      suffixIcon: Icon(Icons.edit, color: Color(0xFFABABAB), size: 18.86),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Color(0xFFABABAB), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Color(0xFFE94C19), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        // 👈 Estilo quando desabilitado
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: Color(0xFFABABAB), width: 2),
      ),
    ),
    style: TextStyle(height: 1.2),
  );
}

Widget _buildStack() {
  return Stack(
    children: [
      Column(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFB23F1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(80),
                bottomRight: Radius.circular(80),
              ),
            ),
          ),
          Container(color: Colors.white),
        ],
      ),
      Center(
        child: Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD9D9D9),
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: AssetImage('lib/presentation/assets/images/user_icon.png'),
              fit: BoxFit.none,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _appBar(BuildContext context) {
  return Container(
    padding: EdgeInsets.only(top: 40, left: 16, right: 16),
    decoration: BoxDecoration(color: Color(0xFFB23F1A)),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
          splashColor: Colors.transparent,
          iconSize: 30,
        ),
      ],
    ),
  );
}
