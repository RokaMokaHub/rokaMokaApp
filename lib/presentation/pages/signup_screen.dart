import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupScreen> {
  // Controla a visibilidade da senha
  bool _obscureTextPassword = true;
  // Controla a visibilidade da confirmação da senha
  bool _obscureTextConfirmPassword = true;

  // Controladores para os campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Variáveis para armazenar mensagens de erro dos campos
  String? _passwordError;
  String? _nameError;
  String? _emailError;
  String? _confirmPasswordError;

  // Cores personalizadas para as bordas dos campos de texto em diferentes estados
  final Color _errorBorderColor = Color(0xFF960000);
  final Color _focusedBorderColor = Color(0xFFE94C19);

  // Indica se o formulário foi submetido
  bool _submitted = false;

  @override
  void dispose() {
    // Libera os recursos dos controladores quando o widget é descartado
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Valida o campo de nome de usuário
  String? _validateName(String name) {
    if (_submitted && name.isEmpty) {
      return 'O nome de usuário é obrigatório.';
    }
    return null;
  }

  // Valida o campo de email
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

  // Valida o campo de senha com critérios de segurança
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

  // Valida o campo de confirmação de senha, comparando com a senha digitada
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

  // Valida todos os campos e simula a criação da conta se todos forem válidos
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
          // Imagem de fundo posicionada no topo da tela
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/presentation/assets/images/backgroundSignup.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),
          // Conteúdo principal dentro de um SafeArea para evitar sobreposição com a barra de status
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
                          // Botão de voltar na parte superior
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          // Conteúdo do formulário expandido para ocupar o espaço restante
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.20),
                                // Container branco com bordas arredondadas para o formulário
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
                                        // Título da tela de cadastro
                                        Text(
                                          'Cadastre-se',
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE94C19),
                                          ),
                                        ),
                                        // Subtítulo da tela de cadastro
                                        Text(
                                          'Crie sua conta.',
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF555555),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        // Campo de texto para o nome de usuário
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
                                        // Campo de texto para o email
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
                                        // Campo de texto para a senha
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
                                        // Campo de texto para confirmar a senha
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
                                        // Botão para criar a conta
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