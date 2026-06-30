import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:roka_moka_app/constants/routes.dart';
import 'package:roka_moka_app/domain/providers/user_provider.dart';
import 'package:roka_moka_app/presentation/widgets/snack_bar_rejeitada.dart';
import '../../domain/services/user_service.dart';
import '../controllers/home_controller.dart';
import '../widgets/snack_bar_aceita.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupScreen> {
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  // Controladores dos campos
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UserService _userService = UserService();

  // Mensagens de erro
  String? _firstNameError;
  String? _lastNameError;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  final Color _errorBorderColor = const Color(0xFF960000);
  final Color _focusedBorderColor = const Color(0xFFE94C19);
  bool _submitted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validações -----------------------
  String? _validateFirstName(String value) {
    final namePattern = RegExp(
      r'^[A-ZÁÉÍÓÚÂÊÎÔÛÃÕÇ][a-zA-ZáéíóúâêîôûãõçÁÉÍÓÚÂÊÎÔÛÃÕÇ]*$',
    );

    if (!_submitted) return null;

    if (value.trim().isEmpty) {
      return 'O nome é obrigatório.';
    }

    if (!namePattern.hasMatch(value.trim())) {
      return 'Nome inválido - deve começar com letra maiúscula e conter apenas letras.';
    }

    return null;
  }

  String? _validateLastName(String value) {
    final namePattern = RegExp(
      r'^[A-ZÁÉÍÓÚÂÊÎÔÛÃÕÇ][a-zA-ZáéíóúâêîôûãõçÁÉÍÓÚÂÊÎÔÛÃÕÇ]*$',
    );

    if (!_submitted) return null;

    if (value.trim().isEmpty) {
      return 'O sobrenome é obrigatório.';
    }

    if (!namePattern.hasMatch(value.trim())) {
      return 'Sobrenome inválido - deve começar com letra maiúscula e conter apenas letras.';
    }

    return null;
  }

  String? _validateName(String name) {
    final trimmedName = name.trim();
    final validPattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (_submitted && trimmedName.isEmpty) {
      return 'O nome de usuário é obrigatório.';
    }
    if (_submitted && !validPattern.hasMatch(trimmedName)) {
      return 'Apenas letras, números, hífen e underline são permitidos.';
    }
    return null;
  }

  String? _validateEmail(String email) {
    final trimmedEmail = email.trim();
    if (_submitted) {
      if (trimmedEmail.isEmpty) {
        return 'O email é obrigatório.';
      }
      if (!RegExp(
        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
      ).hasMatch(trimmedEmail)) {
        return 'Insira um email válido.';
      }
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (_submitted) {
      if (password.isEmpty) return 'A senha é obrigatória.';
      if (password.length < 8) return 'Deve ter no mínimo 8 caracteres.';
      if (!password.contains(RegExp(r'[0-9]')))
        return 'Deve conter pelo menos um número.';
      if (!password.contains(RegExp(r'[A-Z]')))
        return 'Deve conter uma letra maiúscula.';
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Deve conter um caractere especial.';
      }
    }
    return null;
  }

  String? _validateConfirmPassword(String confirmPassword) {
    if (_submitted) {
      if (confirmPassword.isEmpty) return 'Confirme sua senha.';
      if (confirmPassword != _passwordController.text) {
        return 'As senhas não coincidem.';
      }
    }
    return null;
  }

  // Valida e cria conta -----------------
  void _validateAndCreateAccount() async {
    setState(() {
      _submitted = true;
      _firstNameError = _validateFirstName(_firstNameController.text);
      _lastNameError = _validateLastName(_lastNameController.text);
      _nameError = _validateName(_nameController.text);
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
      _confirmPasswordError = _validateConfirmPassword(
        _confirmPasswordController.text,
      );
    });

    if ([
      _firstNameError,
      _lastNameError,
      _nameError,
      _emailError,
      _passwordError,
      _confirmPasswordError,
    ].any((e) => e != null))
      return;

    try {
      await _userService.createUser(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
      );

      context.read<UserProvider>().setRole(UserRole.comum);

      final snackBar = SnackBarAceita(
        titulo: "Seja bem vindo!",
        subtitulo: "Usuário criado com sucesso.",
      ).buildSnackBar(context);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeController()),
      );
    } catch (e) {
      if (kDebugMode) {
        final snackBar = SnackBarRejeitada(
          titulo: e.toString(),
          subtitulo: "Tente novamente!",
        ).buildSnackBar(context);
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  // Widget ------------------------
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
              height: MediaQuery.of(context).size.height * 0.35,
            ),
          ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.20,
                                ),
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(24),
                                    decoration: const BoxDecoration(
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
                                        const SizedBox(height: 10),
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
                                        const SizedBox(height: 30),

                                        // Nome
                                        _buildTextField(
                                          controller: _firstNameController,
                                          label: 'Nome',
                                          icon: Icons.badge_outlined,
                                          error: _firstNameError,
                                          validator: _validateFirstName,
                                          onErrorChanged: (e) => _firstNameError = e,
                                        ),
                                        const SizedBox(height: 16),

                                        // Sobrenome
                                        _buildTextField(
                                          controller: _lastNameController,
                                          label: 'Sobrenome',
                                          icon: Icons.person_outline,
                                          error: _lastNameError,
                                          validator: _validateLastName,
                                          onErrorChanged: (e) => _lastNameError = e,
                                        ),
                                        const SizedBox(height: 16),

                                        // Usuário
                                        _buildTextField(
                                          controller: _nameController,
                                          label: 'Usuário',
                                          icon: Icons.account_circle_outlined,
                                          error: _nameError,
                                          validator: _validateName,
                                          onErrorChanged: (e) => _nameError = e,
                                        ),
                                        const SizedBox(height: 16),

                                        // Email
                                        _buildTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          icon: Icons.alternate_email,
                                          error: _emailError,
                                          validator: _validateEmail,
                                          onErrorChanged: (e) => _emailError = e,
                                        ),
                                        const SizedBox(height: 16),

                                        // Senha
                                        _buildTextField(
                                          controller: _passwordController,
                                          label: 'Senha',
                                          icon: Icons.lock_outline,
                                          error: _passwordError,
                                          validator: _validatePassword,
                                          onErrorChanged: (e) => _passwordError = e,
                                          obscureText: _obscureTextPassword,
                                          onSuffixTap: () {
                                            setState(
                                              () =>
                                                  _obscureTextPassword =
                                                      !_obscureTextPassword,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 16),

                                        // Confirmar senha
                                        _buildTextField(
                                          controller:
                                              _confirmPasswordController,
                                          label: 'Confirmar Senha',
                                          icon: Icons.lock_outline,
                                          error: _confirmPasswordError,
                                          validator: _validateConfirmPassword,
                                          onErrorChanged: (e) => _confirmPasswordError = e,
                                          obscureText:
                                              _obscureTextConfirmPassword,
                                          onSuffixTap: () {
                                            setState(
                                              () =>
                                                  _obscureTextConfirmPassword =
                                                      !_obscureTextConfirmPassword,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 30),

                                        GestureDetector(
                                          onTap: _validateAndCreateAccount,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 120,
                                              vertical: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
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

  // Builder reutilizável para TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? error,
    required String? Function(String) validator,
    required void Function(String?) onErrorChanged,
    bool obscureText = false,
    VoidCallback? onSuffixTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: (value) {
            setState(() {
              onErrorChanged(validator(value));
            });
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFFABABAB)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 11.5,
                bottom: 11.5,
              ),
              child: Icon(
                icon,
                color: error == null ? _focusedBorderColor : _errorBorderColor,
              ),
            ),
            suffixIcon:
                onSuffixTap != null
                    ? IconButton(
                      icon: Icon(
                        obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFFABABAB),
                      ),
                      onPressed: onSuffixTap,
                    )
                    : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 26.0,
              vertical: 12.0,
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
        if (_submitted && error != null)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 6.0),
            child: Text(
              error!,
              style: TextStyle(
                color: _errorBorderColor,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }
}
