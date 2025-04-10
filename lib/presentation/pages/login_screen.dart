import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
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
              'lib/presentation/assets/images/backgroundLogin.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'Olá!',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE94C19),
                        ),
                      ),
                      Text(
                        'A cada QR code, uma nova descoberta.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF9E2700),
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        'Já tem uma conta?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botão "Acessar"
                      GestureDetector(
                        // Envolve o Container inteiro
                        onTap: () {
                          Navigator.pushNamed(context, '/connect');
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 120,
                            vertical: 14,
                          ),
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
                              'Acessar',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Usuário novo?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 16),
                      // Botão "Cadastre-se"
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFFE94C19),
                          padding: EdgeInsets.symmetric(
                            horizontal: 127,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          side: BorderSide(color: Color(0xFFE94C19)),
                        ),
                        child: Text(
                          'Cadastre-se',
                          style: GoogleFonts.poppins(
                            color: Color(0xFFE94C19),
                            fontWeight: FontWeight.w600,
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
    );
  }
}
