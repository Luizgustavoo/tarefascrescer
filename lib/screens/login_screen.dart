import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarefas_projetocrescer/screens/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bem-vindo(a)!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A3DE8),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Entre na sua conta para continuar',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 48),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  hintText: 'seu@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF6A3DE8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 20),

              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF6A3DE8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.visibility_off, color: Colors.grey),
                    onPressed: () {},
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                style: GoogleFonts.poppins(),
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Esqueceu a senha?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6A3DE8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A3DE8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Entrar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text(
              //       'Não tem uma conta?',
              //       style: GoogleFonts.poppins(color: Colors.grey[700]),
              //     ),
              //     TextButton(
              //       onPressed: () {},
              //       child: Text(
              //         'Cadastre-se',
              //         style: GoogleFonts.poppins(
              //           color: const Color(0xFF6A3DE8),
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
