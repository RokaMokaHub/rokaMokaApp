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
  String? _confirmPasswordError;

  final Color _errorBorderColor = Color(0xFF960000);
  final Color _focusedBorderColor = Color(0xFFE94C19);
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String name) {
    if (_submitted && name.isEmpty) {
      return 'O nome de usuário é obrigatório.';
    }
    return null;
  }

  String? _validateEmail(String email) {
    if (_submitted) {
      if (email.isEmpty) {
        return 'O email é obrigatório.';
      }
      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
        return 'Insira um email válido.';
      }
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (_submitted) {
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
    }
    return null;
  }

  String? _validateConfirmPassword(String confirmPassword) {
    if (_submitted) {
      if (confirmPassword.isEmpty) {
        return 'Confirme sua senha.';
      }
      if (confirmPassword != _passwordController.text) {
        return 'As senhas não coincidem.';
      }
    }
    return null;
  }

  void _validateAndCreateAccount() {
    setState(() {
      _submitted = true;
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(_confirmPasswordController.text);
    });

    if (_nameError != null || _emailError != null || _passwordError != null || _confirmPasswordError != null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Conta criada com sucesso (simulação)')),
    );
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
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
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
                                            labelText: 'Usuário',
                                            errorText: _submitted ? _nameError : null,
                                            labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(left: 20.0, top: 11.5, bottom: 11.5),
                                              child: Icon(Icons.person_outline_sharp, color: _nameError == null ? _focusedBorderColor : _errorBorderColor),
                                            ),
                                            contentPadding: EdgeInsets.only(left: 26.0, top: 10.0, bottom: 10.0, right: 4.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
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
                                            errorText: _submitted ? _emailError : null,
                                            labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(left: 20.0, top: 11.5, bottom: 11.5),
                                              child: Icon(Icons.alternate_email, color: _emailError == null ? _focusedBorderColor : _errorBorderColor),
                                            ),
                                            contentPadding: EdgeInsets.only(left: 26.0, top: 10.0, bottom: 10.0, right: 4.0),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
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
                                            errorText: _submitted ? _passwordError : null,
                                            labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(left: 20.0, top: 11.5, bottom: 11.5),
                                              child: Icon(Icons.lock_outline_rounded, color: _passwordError == null ? _focusedBorderColor : _errorBorderColor),
                                            ),
                                            contentPadding: EdgeInsets.only(left: 26.0, top: 10.0, bottom: 10.0, right: 4.0),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureTextPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        TextField(
                                          controller: _confirmPasswordController,
                                          obscureText: _obscureTextConfirmPassword,
                                          onChanged: (value) {
                                            setState(() {
                                              _confirmPasswordError = _validateConfirmPassword(value);
                                            });
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Confirmar Senha',
                                            errorText: _submitted ? _confirmPasswordError : null,
                                            labelStyle: TextStyle(color: Color(0xFFABABAB)),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(left: 20.0, top: 11.5, bottom: 11.5),
                                              child: Icon(Icons.lock_outline_rounded, color: _confirmPasswordError == null ? _focusedBorderColor : _errorBorderColor),
                                            ),
                                            contentPadding: EdgeInsets.only(left: 26.0, top: 10.0, bottom: 10.0, right: 4.0),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureTextConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _focusedBorderColor, width: 2.0),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
                                            ),
                                            focusedErrorBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30.0),
                                              borderSide: BorderSide(color: _errorBorderColor, width: 2.0),
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}