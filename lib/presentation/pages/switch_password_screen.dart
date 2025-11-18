import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:roka_moka_app/constants/colors.dart';
import 'package:roka_moka_app/domain/services/auth_service.dart';
import 'package:roka_moka_app/domain/services/user_service.dart';

import '../widgets/snack_bar_aceita.dart';
import '../widgets/snack_bar_rejeitada.dart';

class SwitchPasswordScreen extends StatefulWidget {
  const SwitchPasswordScreen({super.key});

  @override
  State<SwitchPasswordScreen> createState() => _SwitchPasswordScreenState();
}

class _SwitchPasswordScreenState extends State<SwitchPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAntigaController = TextEditingController();
  final _senhaAtualController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final userService = UserService();
  final authService = AuthService();
  String _email = '';
  String _name = '';

  bool _obscureAntiga = true;
  bool _obscureAtual = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _senhaAntigaController.dispose();
    _senhaAtualController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  Future<void> _loadUserInfo() async {
    final fetchedEmail = await authService.getEmail();
    final fetchedUserName = await authService.getUserName();
    setState(() {
      _email = fetchedEmail!;
      _name = fetchedUserName!;
    });
  }

  void _trocarSenha() async {
    if (_formKey.currentState!.validate()) {
      try {
        await userService.resetPassword(
          _email,
          _senhaAntigaController.text,
          _senhaAtualController.text,
          _name,
        );

        final snackBar = SnackBarAceita(
          titulo: "Sucesso!",
          subtitulo: "Sua senha foi alterada com sucesso.",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        Navigator.pop(context);
      } catch (e) {
        if (kDebugMode) {
          final snackBar = SnackBarRejeitada(
            titulo: _verificaRetornoLoginInvalido(e.toString()),
            subtitulo: "Tente novamente!",
          ).buildSnackBar(context);
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    }
  }

  String _verificaRetornoLoginInvalido(String retorno) {
    if (retorno == 'Unauthorized') {
      return 'Credenciais inválidas, senha não foi alterada!';
    }
    if (retorno == "A senha informada é inválida"){
      return 'A senha informada é inválida';
    }
    return 'Erro desconhecido';
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'A senha é obrigatória.';
    }
    if (password.length < 8) return 'Deve ter no mínimo 8 caracteres.';
    if (!password.contains(RegExp(r'[0-9]')))
      return 'Deve conter pelo menos um número.';
    if (!password.contains(RegExp(r'[A-Z]')))
      return 'Deve conter uma letra maiúscula.';
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Deve conter um caractere especial.';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
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
            'Alterar senha',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Preencha os seguintes campos para redefinir sua senha.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),

              // Senha antiga
              _buildPasswordField(
                label: 'Senha antiga',
                controller: _senhaAntigaController,
                obscure: _obscureAntiga,
                onToggle: () {
                  setState(() => _obscureAntiga = !_obscureAntiga);
                },
              ),
              const SizedBox(height: 16),

              // Senha atual
              _buildPasswordField(
                label: 'Senha atual',
                controller: _senhaAtualController,
                obscure: _obscureAtual,
                onToggle: () {
                  setState(() => _obscureAtual = !_obscureAtual);
                },
              ),
              const SizedBox(height: 16),

              // Confirmar senha
              _buildPasswordField(
                label: 'Confirmar senha',
                controller: _confirmarSenhaController,
                obscure: _obscureConfirmar,
                onToggle: () {
                  setState(() => _obscureConfirmar = !_obscureConfirmar);
                },
                validator: (value) {
                  if (value != _senhaAtualController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Botão
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(primaryColorGradient),
                      Color(secondaryColorGradient),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: _trocarSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Trocar senha',
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Campo obrigatório';
            }
            return null;
          },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.grey, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFFF8734), width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.redAccent, width: 3),
        ),
      ),
    );
  }
}
