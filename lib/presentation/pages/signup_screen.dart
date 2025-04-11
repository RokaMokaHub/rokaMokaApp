import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupScreen> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _passwordError;
  String? _nameError;
  String? _emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String name) {
    if (name.isEmpty) {
      return 'O nome de usuário é obrigatório.';
    }
    return null;
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'O email é obrigatório.';
    }
    // Expressão regular para validar o formato do email
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
      return 'Insira um email válido.';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'A senha é obrigatória.';
    }
    if (password.length < 8) {
      return 'Deve ter no mínimo 8 caracteres.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Deve conter pelo menos um número.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Deve conter pelo menos uma letra maiúscula.';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Deve conter pelo menos um caractere especial.';
    }
    return null;
  }

  void _validateAndCreateAccount() {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _nameError = _validateName(name);
      _emailError = _validateEmail(email);
      _passwordError = _validatePassword(password);
    });

    if (_nameError != null || _emailError != null || _passwordError != null) {
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Conta criada com sucesso (simulação)')),
    );
    // lógica de criação de conta
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/presentation/assets/images/backgroundSignup.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.48,
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
                  child: Align(
                    alignment: Alignment.bottomCenter,
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
                              'Cadastre-se',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE94C19),
                              ),
                            ),
                            Text(
                              'Crie sua conta.',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 30),
                            TextField(
                              controller: _nameController,
                              onChanged: (value) {
                                setState(() {
                                  _nameError = _validateName(value);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Username',
                                errorText: _nameError,
                                labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                prefixIcon: Icon(Icons.person, color: Color(0xFFE94C19)),
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
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              onChanged: (value) {
                                setState(() {
                                  _emailError = _validateEmail(value);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Email',
                                errorText: _emailError,
                                labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                prefixIcon: Icon(Icons.alternate_email, color: Color(0xFFE94C19)),
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
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureTextPassword,
                              onChanged: (value) {
                                setState(() {
                                  _passwordError = _validatePassword(value);
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                errorText: _passwordError, 
                                labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                prefixIcon: Icon(Icons.lock_outline_rounded, color: Color(0xFFE94C19)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureTextPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFFABABAB),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextPassword = !_obscureTextPassword;
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
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureTextConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar Senha',
                                labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                prefixIcon: Icon(Icons.lock_rounded, color: Color(0xFFE94C19)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureTextConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Color(0xFFABABAB),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureTextConfirmPassword = !_obscureTextConfirmPassword;
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
                              ),
                            ),
                            SizedBox(height: 30),
                            GestureDetector(
                              onTap: _validateAndCreateAccount,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 120, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFB23F1A), Color(0xFFE94C19)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Center(
                                  child: Text(
                                    'Criar conta',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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