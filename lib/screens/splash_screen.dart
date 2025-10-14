// FILE: lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart'; // Ajuste o import
import 'package:tarefas_projetocrescer/screens/login_screen.dart'; // Ajuste o import
import 'package:tarefas_projetocrescer/screens/main_screen.dart'; // Ajuste o import

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Adiciona um pequeno delay para a UI e depois tenta o login automático
    Future.delayed(const Duration(milliseconds: 500), _tryAutoLogin);
  }

  Future<void> _tryAutoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bool hasToken = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (hasToken) {
      // Se encontrou um token, vai para a tela principal
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      // Se não, vai para a tela de login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
