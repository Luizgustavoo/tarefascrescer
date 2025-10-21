import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/user.dart';

class AuthService {
  static const String _baseUrl =
      'http://api.tasks.projetocrescerarapongas.org.br/api';

  Future<(User, String)> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'];
        if (data == null || data['user'] == null || data['token'] == null) {
          throw Exception('Resposta da API inválida ou incompleta.');
        }

        final User user = User.fromJson(data['user']);
        final String accessToken = data['token']['access_token'];

        return (user, accessToken);
      } else {
        String errorMessage = 'Falha na autenticação. Tente novamente.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData != null && errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          } catch (e) {
            print("Erro ao decodificar JSON de erro: $e");
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro de conexão. Verifique sua internet.');
    }
  }
}
