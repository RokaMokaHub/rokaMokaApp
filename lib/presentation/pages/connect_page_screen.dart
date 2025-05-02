import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConnectScreen extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectScreen> {
  // Controle do estado da senha visível
  bool _obscureText = true;

  // Controladores dos campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variáveis para exibir mensagens de erro
  String? _usernameErrorText;
  String? _passwordErrorText;

  // Variáveis para controle de validade dos campos
  bool _isUsernameValid = true;
  bool _isPasswordValid = true;

  // Variável para indicar se o formulário foi submetido (Para começar a exibir os erros)
  bool _submitted = false;

  // Cores personalizadas para as bordas dos campos de texto
  final Color _errorBorderColor = Color(0xFF960000);
  final Color _focusedBorderColor = Color(0xFFE94C19);

  // URL base da API
  final String _baseUrl = 'http://10.0.2.2:8080';

  //'http://localhost:8080' -> no insomnia funciona
  final String _loginEndpoint = '/user/login';

  @override
  void dispose() {
    // Limpa os controladores quando o widget é removido
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função para validar o campo de username
  void _validateUsername() {
    final username = _usernameController.text;
    if (_submitted) {
      setState(() {
        if (username.isEmpty) {
          _usernameErrorText = 'O nome de usuário deve estar preenchido.';
          _isUsernameValid = false;
        } else {
          _usernameErrorText = null;
          _isUsernameValid = true;
        }
      });
    } else {
      setState(() {
        _usernameErrorText = null;
        _isUsernameValid = true;
      });
    }
  }

  // Função para validar o campo de senha
  void _validatePassword() {
    if (_submitted) {
      setState(() {
        _passwordErrorText =
            _passwordController.text.isEmpty
                ? 'A senha deve estar preenchida.'
                : null;
        _isPasswordValid = _passwordController.text.isNotEmpty;
      });
    } else {
      setState(() {
        _passwordErrorText = null;
        _isPasswordValid = true;
      });
    }
  }

  //Função de Login com Username
  Future<void> _login() async {
    if (_isUsernameValid && _isPasswordValid) {
      try {
        final Uri url = Uri.parse('$_baseUrl$_loginEndpoint');
        final String credentials =
            '${_usernameController.text}:${_passwordController.text}';
        final String base64Credentials = base64Encode(utf8.encode(credentials));

        final response = await http.get(
          url,
          headers: {'Authorization': 'Basic $base64Credentials'},
        );

        if (response.statusCode == 200) {
          // Login bem-sucedido
          final responseData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login realizado com sucesso!')),
          );
          Navigator.pushNamed(
            context,
            '/profile',
          ); // Navegar para a próxima tela
        } else {
          // Falha no login
          String errorMessage = 'Erro ao fazer login';
          if (response.body.isNotEmpty) {
            try {
              final errorData = jsonDecode(response.body);
              errorMessage = errorData['error'] ?? errorMessage;
            } catch (e) {
              print('Erro ao decodificar resposta de erro: $e');
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no login: $errorMessage')),
          );
        }
      } catch (error) {
        print('Erro de conexão: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao conectar com o servidor')),
        );
      }
    }
  }

  // Função para validar ambos os campos e tentar o login
  void _validateFields() {
    setState(() {
      _submitted = true;
      _validateUsername();
      _validatePassword();
    });

    // Se ambos os campos são válidos, faz a requisição de login
    if (_isUsernameValid && _isPasswordValid) {
      _login();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo posicionada no topo
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
          // Conteúdo principal dentro de um SafeArea para evitar sobreposição com a barra de status
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Botão de voltar
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
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
                                // Espaçamento superior
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.15,
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        // Título "Login"
                                        Text(
                                          'Login',
                                          style: GoogleFonts.poppins(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE94C19),
                                          ),
                                        ),
                                        // Subtítulo "Conecte-se na sua conta"
                                        Text(
                                          'Conecte-se na sua conta',
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFF555555),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        // Campo de texto para o username
                                        TextField(
                                          controller: _usernameController,
                                          onChanged: (value) {
                                            if (_submitted) {
                                              _validateUsername();
                                            } else {
                                              setState(() {
                                                _usernameErrorText = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Usuário',
                                            labelStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFABABAB),
                                            ),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                left: 20.0,
                                                top: 11.5,
                                                bottom: 11.5,
                                              ),
                                              child: Icon(
                                                Icons.person_outline,
                                                color:
                                                    _usernameErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.only(
                                              top: 10.0,
                                              bottom: 10.0,
                                              left: 26.0,
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color:
                                                    _usernameErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color:
                                                    _usernameErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color: _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        30.0,
                                                      ),
                                                  borderSide: BorderSide(
                                                    color: _errorBorderColor,
                                                    width: 2.0,
                                                  ),
                                                ),
                                            errorText:
                                                _submitted
                                                    ? _usernameErrorText
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        // Campo de texto para a senha
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: _obscureText,
                                          onChanged: (value) {
                                            if (_submitted) {
                                              _validatePassword();
                                            } else {
                                              setState(() {
                                                _passwordErrorText = null;
                                              });
                                            }
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Senha',
                                            labelStyle: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFABABAB),
                                            ),
                                            prefixIcon: Padding(
                                              padding: EdgeInsets.only(
                                                left: 20.0,
                                                top: 11.5,
                                                bottom: 11.5,
                                              ),
                                              child: Icon(
                                                Icons.lock_rounded,
                                                color:
                                                    _passwordErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                              ),
                                            ),
                                            contentPadding: EdgeInsets.only(
                                              top: 10.0,
                                              bottom: 10.0,
                                              left: 26.0,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscureText
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                        .visibility_off_outlined,
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
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color:
                                                    _passwordErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color:
                                                    _passwordErrorText == null
                                                        ? _focusedBorderColor
                                                        : _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                width: 2.0,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              borderSide: BorderSide(
                                                color: _errorBorderColor,
                                                width: 2.0,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        30.0,
                                                      ),
                                                  borderSide: BorderSide(
                                                    color: _errorBorderColor,
                                                    width: 2.0,
                                                  ),
                                                ),
                                            errorText:
                                                _submitted
                                                    ? _passwordErrorText
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        // Botão "Esqueceu a senha?" alinhado à direita
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '     Fale com o administrador (53) 9xxxx - xxxx',
                                                  ),
                                                ),
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
                                        // Botão "Entrar" com gradiente
                                        GestureDetector(
                                          onTap: () {
                                            _validateFields();
                                          },
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
                                              borderRadius:
                                                  BorderRadius.circular(32),
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
                                        // Separador "OU"
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
                                        // Botão "Entrar de forma anônima"
                                        ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Entrar de forma anônima',
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFB1B1B1),
                                            foregroundColor: Colors.black,
                                            minimumSize: Size(
                                              double.infinity,
                                              50,
                                            ),
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
