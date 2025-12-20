import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/constants/webservice.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';

import '../../constants/routes.dart';
import '../widgets/snack_bar_aceita.dart';
import '../widgets/snack_bar_rejeitada.dart';

class SendEmailForgotPasswordScreen extends StatefulWidget {
  const SendEmailForgotPasswordScreen({super.key});

  @override
  State<SendEmailForgotPasswordScreen> createState() =>
      _SendEmailForgotPasswordScreenState();
}

class _SendEmailForgotPasswordScreenState
    extends State<SendEmailForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final userService = UserService();
  final authService = AuthService();

  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _enviarEmail() async {
    try {
      await userService.sendEmailForgotPassword(_emailController.text);
      final snackBar = SnackBarAceita(
        titulo: "Sucesso!",
        subtitulo: "Um email foi enviado para você com as instruções para redefinir sua senha.",
      ).buildSnackBar(context);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } catch (e) {
      final snackBar = SnackBarRejeitada(
        titulo: _verificaRetornoLoginInvalido(e.toString()),
        subtitulo: "Tente novamente!",
      ).buildSnackBar(context);

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  String _verificaRetornoLoginInvalido(String retorno) {
    if (retorno == 'Unauthorized') {
      return 'Credenciais inválidas, senha não foi alterada!';
    }
    if (retorno == "A senha informada é inválida") {
      return 'A senha informada é inválida';
    }
    return 'Erro desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(primaryColorGradient),
                  Color(secondaryColorGradient),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          title: const Text(
            'Esqueceu a senha?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Insira seu email:',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              // Usuario
              _buildUserField(
                label: 'Email',
                controller: _emailController,
                validator:
                    (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 30),
              // Botão enviar user
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(primaryColorGradient),
                      Color(secondaryColorGradient),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: _enviarEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Próximo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person, color: Colors.orangeAccent),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.deepOrange, width: 2.5),
        ),
      ),
    );
  }
}
