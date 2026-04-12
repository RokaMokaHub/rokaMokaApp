import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/domain/services/login_service.dart';
import 'package:roka_moka_app/presentation/controllers/home_controller.dart';

import '../../constants/routes.dart';
import '../../domain/services/user_service.dart';
import '../widgets/snack_bar_aceita.dart';
import '../widgets/snack_bar_rejeitada.dart';
import '../widgets/urgent_alert_dialog.dart';

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

  // Instância do LoginService
  final LoginService _loginService = LoginService();
  final UserService _userService = UserService();

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

  // Função de Login utilizando o LoginService
  Future<void> _login() async {
    if (_isUsernameValid && _isPasswordValid) {
      try {
        await _loginService.login(
          _usernameController.text,
          _passwordController.text,
        );

        // Buscar a role real do usuário após login
        final userInfo = await _userService.getUserInfo();
        final roleFromAPI = userInfo['body']['role'];
        final roleEnum = _convertRoleStringToEnum(roleFromAPI);

        // Atualizar no provider
        context.read<UserProvider>().setRole(roleEnum);

        final snackBar = SnackBarAceita(
          titulo: "Login realizado com sucesso!",
          subtitulo: "Bem-vindo(a) ao Roka Moka!",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeController()),
          (route) => false,
        );
      } catch (error) {
        final snackBar = SnackBarRejeitada(
          titulo: _verificaRetornoLoginInvalido(error.toString()),
          subtitulo: "Tente novamente!",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  //Metodo para login anonimo
  Future<void> _loginAnonimo() async {
    if (_usernameController.text.isEmpty) {
      final snackBar = SnackBarRejeitada(
        titulo: "Login Recusado",
        subtitulo: "O nome de usuário deve estar preenchido.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Mostra o alerta de confirmação
    final shouldProceed = await showDialog<bool>(
      context: context,
      builder:
          (context) => const UrgentAlertDialog(
            title: 'Aviso',
            content:
                'Se você entrar de forma anônima e desinstalar ou limpar os dados do app, '
                'sua conta será perdida permanentemente. Deseja continuar?',
          ),
    );

    if (shouldProceed != true) return; // Se não confirmou, cancela o login

    try {
      await _userService.createAnonymousUser(_usernameController.text);
      final snackBar = SnackBarAceita(
        titulo: "Login realizado com sucesso!",
        subtitulo: "Bem-vindo(a) ao Roka Moka!",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      context.read<UserProvider>().setRole(UserRole.anon);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeController()),
        (route) => false,
      );
    } catch (error) {
      final snackBar = SnackBarRejeitada(
        titulo: _verificaRetornoLoginInvalido(error.toString()),
        subtitulo: "Tente novamente!",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  UserRole _convertRoleStringToEnum(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.administrador;
      case 'comum':
        return UserRole.comum;
      case 'curador':
        return UserRole.curador;
      case 'pesquisador':
        return UserRole.pesquisador;
      default:
        return UserRole.comum; // fallback seguro
    }
  }

  String _verificaRetornoLoginInvalido(String retorno) {
    if (retorno == 'Unauthorized') {
      return 'Credenciais inválidas, login não realizado!';
    }
    if (retorno == "O nome do usuário já está sendo utilizado") {
      return 'O nome do usuário já está sendo utilizado!';
    }
    return 'Erro desconhecido';
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
                            padding: const EdgeInsets.all(8.0),
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
                                            color: Color(titleColor),
                                          ),
                                        ),
                                        // Subtítulo "Conecte-se na sua conta"
                                        Text(
                                          'Conecte-se na sua conta',
                                          style: GoogleFonts.poppins(
                                            color: Color(greySubtitleColor),
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
                                              color: Color(borderColor),
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
                                                        ? Color(0xFFE94C19)
                                                        : Color(0xFF960000),
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
                                              color: Color(borderColor),
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
                                                        ? Color(0xFFE94C19)
                                                        : Color(0xFF960000),
                                              ),
                                            ),
                                            errorText:
                                                _submitted
                                                    ? _passwordErrorText
                                                    : null,
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        GestureDetector(
                                          onTap:
                                              () => Navigator.pushNamed(
                                                context,
                                                sendEmailForgotPasswordRoute,
                                              ),
                                          child: Container(
                                            child: Align(
                                              alignment:
                                                  AlignmentGeometry.topRight,
                                              child: Text(
                                                'Esqueceu a senha?',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                        // Botão "Entrar"
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
                                                  Color(primaryColorGradient),
                                                  Color(secondaryColorGradient),
                                                ],
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
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SafeArea(
                                            child: SingleChildScrollView(
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Ou',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: Color(
                                                              greySubtitleColor,
                                                            ),
                                                          ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _loginAnonimo();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 60,
                                                              vertical: 16,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                32,
                                                              ),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Entrar de forma anônima',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 15,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
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
