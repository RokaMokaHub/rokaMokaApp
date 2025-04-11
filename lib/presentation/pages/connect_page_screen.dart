import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectScreen> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _emailErrorText;
  String? _passwordErrorText;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      if (email.isEmpty) {
        _emailErrorText = 'O email não pode estar vazio';
        _isEmailValid = false;
      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
        _emailErrorText = 'Insira um email válido';
        _isEmailValid = false;
      } else {
        _emailErrorText = null;
        _isEmailValid = true;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordErrorText = _passwordController.text.isEmpty ? 'A senha não pode estar vazia' : null;
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });
  }

  void _validateFields() {
    _validateEmail();
    _validatePassword();

    if (_isEmailValid && _isPasswordValid) {
      //Lógica de autenticação:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Autenticando com: ${_emailController.text}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/presentation/assets/images/backgroundConnect.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE94C19),
                                  ),
                                ),
                                Text(
                                  'Conecte-se na sua conta',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 30),
                                TextField(
                                  controller: _emailController,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isEmpty) {
                                        _emailErrorText = 'O email não pode estar vazio';
                                        _isEmailValid = false;
                                      } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
                                        _emailErrorText = 'Insira um email válido';
                                        _isEmailValid = false;
                                      } else {
                                        _emailErrorText = null;
                                        _isEmailValid = true;
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFABABAB),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.alternate_email,
                                      color: Color(0xFFE94C19),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color:Color(0xFFE94C19)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color:  Color(0xFFE94C19)),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    errorText: _emailErrorText,
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscureText,
                                  onChanged: (value) {
                                    setState(() {
                                      _passwordErrorText = value.isEmpty ? 'A senha não pode estar vazia' : null;
                                      _isPasswordValid = value.isNotEmpty;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    labelStyle: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFABABAB),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_rounded,
                                      color:  Color(0xFFE94C19),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Color(0xFFABABAB),
                                        size: 25,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color: Color(0xFFE94C19)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide(color: Color(0xFFE94C19)),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                    errorText: _passwordErrorText,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('     Fale com o administrador (53) 9xxxx - xxxx')),
                                      );
                                    },
                                    child: Text(
                                      'Esqueceu a senha?',
                                      style: GoogleFonts.poppins(
                                        color: Color(0xFFABABAB),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                GestureDetector(
                                  onTap: _validateFields,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 120,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFB23F1A),
                                          Color(0xFFE94C19),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Entrar',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Center(
                                  child: Text(
                                    'OU',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF8A8A8A),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Entrar de forma anônima'),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFB1B1B1),
                                    foregroundColor: Colors.black,
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  child: Text(
                                    'Entrar de forma anônima',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}