import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final bool submitted;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    this.submitted = false,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  String? _errorText;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String? _validatePassword(String password) {
    if (!widget.submitted) return null;

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

  @override
  void didUpdateWidget(covariant PasswordTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Valida novamente se o botão "Salvar" foi pressionado (submitted mudou)
    if (widget.submitted != oldWidget.submitted && widget.submitted == true) {
      setState(() {
        _errorText = _validatePassword(widget.controller.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      onChanged: (value) {
        if (widget.submitted) {
          setState(() {
            _errorText = _validatePassword(value);
          });
        }
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),
        hintText: widget.placeholder,
        hintStyle: const TextStyle(color: Color(0xFFABABAB)),
        errorText: _errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color:
                _obscureText
                    ? const Color(0xFFABABAB)
                    : const Color(0xFFE94C19),
            size: 18.86,
          ),
          onPressed: _togglePasswordVisibility,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFABABAB), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Color(0xFFE94C19), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      style: const TextStyle(height: 1.2),
    );
  }
}
