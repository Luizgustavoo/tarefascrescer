// FILE: lib/services/project_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/project.dart';
import 'api_service.dart';

class ProjectService {
  // --- Lista todos os projetos ---
  Future<List<Project>> list(String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/projects/list');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];
          return dataList.map((json) => Project.fromJson(json)).toList();
        } else {
          throw Exception('Formato de resposta da API de projetos inesperado.');
        }
      } else {
        throw Exception('Falha ao carregar a lista de projetos.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Registra um novo projeto ---
  Future<Project> register(Project project, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/projects/register');
    try {
      final response = await http.post(
        url,
        headers: ApiService.getHeaders(authToken: token),
        // Usa o método toJson() do nosso model para criar o corpo da requisição
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data')) {
          return Project.fromJson(decodedBody['data']);
        } else {
          return Project.fromJson(decodedBody);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Falha ao cadastrar o projeto.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
