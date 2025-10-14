// FILE: lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tarefas_projetocrescer/models/user.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;
  String? _token;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  // Função de Login atualizada para salvar os dados
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final (loggedInUser, receivedToken) = await _authService.login(
        email,
        password,
      );

      _user = loggedInUser;
      _token = receivedToken;

      // Salva os dados no SharedPreferences
      await _saveAuthData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // NOVO: Função para tentar o login automático
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return false;
    }

    _token = prefs.getString('authToken');
    // Aqui você poderia também carregar os dados do usuário salvos, se desejar
    // Ex: _user = User.fromJson(jsonDecode(prefs.getString('userData')));

    notifyListeners();
    return true;
  }

  // NOVO: Função de Logout atualizada para limpar os dados
  Future<void> logout() async {
    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    // await prefs.remove('userData'); // Se você salvar os dados do usuário também

    notifyListeners();
  }

  // NOVO: Função privada para salvar os dados de autenticação
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', _token!);
    // Opcional: Salvar os dados do usuário como uma string JSON
    // final userData = jsonEncode({'id': _user!.id, 'name': _user!.name, ...});
    // await prefs.setString('userData', userData);
  }
}
