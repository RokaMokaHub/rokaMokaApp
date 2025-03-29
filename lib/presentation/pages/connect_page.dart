import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'lib/presentation/assets/images/backgroundConnect.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.3,
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
                              'Login',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE94C19),
                              ),
                            ),
                            Text(
                              'Conecte-se na sua conta',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 30),
                            TextField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFABABAB),
                                ),
                                prefixIcon: Icon(
                                  Icons.alternate_email,
                                  color: Color(0xFFE94C19),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Color(0xFFE94C19)), // Cor da borda igual ao texto
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Color(0xFFE94C19)), // Cor da borda igual ao texto
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFABABAB),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_rounded,
                                  color: Color(0xFFE94C19),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
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
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Color(0xFFE94C19)), // Cor da borda igual ao texto
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                  borderSide: BorderSide(color: Color(0xFFE94C19)), // Cor da borda igual ao texto
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Esqueceu a senha')),
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
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Autenticação via email/senha',
                                    ),
                                  ),
                                );
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
                                  borderRadius: BorderRadius.circular(32),
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
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Autenticação via Google'),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                'lib/presentation/assets/icons/google.png',
                                height: 24,
                              ),
                              label: Text(
                                'Faça login com Google',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Autenticação via Apple'),
                                  ),
                                );
                              },
                              icon: Image.asset('lib/presentation/assets/icons/apple.png', height: 24),
                              label: Text(
                                'Faça login com Apple',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
                              ),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Autenticação via Facebook'),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                'lib/presentation/assets/icons/facebook.png',
                                height: 24,
                              ),
                              label: Text(
                                'Faça login com Facebook',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF555555),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                minimumSize: Size(double.infinity, 50),
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