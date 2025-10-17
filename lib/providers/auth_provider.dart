// FILE: lib/providers/auth_provider.dart

import 'dart:convert';
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

      // Agora esta função salva o token E o usuário
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

  // ALTERADO: Agora também carrega e recria o objeto User
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      return false;
    }

    _token = prefs.getString('authToken');

    // Carrega a string JSON do usuário, se existir
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      // Converte a string de volta para um Map e depois para um objeto User
      _user = User.fromJson(jsonDecode(userDataString));
    }

    notifyListeners();
    return _token != null;
  }

  // ALTERADO: Agora também limpa os dados do usuário do SharedPreferences
  Future<void> logout() async {
    _user = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userData'); // Limpa o usuário

    notifyListeners();
  }

  // ALTERADO: Agora salva o token e o usuário
  Future<void> _saveAuthData() async {
    if (_token == null || _user == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', _token!);

    // Converte o objeto User para um Map e depois para uma string JSON para salvar
    final userDataString = jsonEncode(_user!.toJson());
    await prefs.setString('userData', userDataString);
  }
}
