import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/project.dart';
import 'api_service.dart';

class ProjectService {
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

  Future<void> delete(int projectId, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/projects/delete/$projectId');
    try {
      final response = await http.delete(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        String errorMessage = 'Falha ao deletar o projeto.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData['message'] != null) {
              errorMessage = errorData['message'];
            }
          } catch (_) {}
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Project> update(Project project, String token) async {
    if (project.id == null) {
      throw Exception("ID do projeto inválido para atualização.");
    }
    final url = Uri.parse(
      '${ApiService.baseUrl}/projects/update/${project.id}',
    );
    try {
      final response = await http.put(
        url,
        headers: ApiService.getHeaders(authToken: token),
        body: jsonEncode(project.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data')) {
          return Project.fromJson(decodedBody['data']);
        } else {
          return Project.fromJson(decodedBody);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Falha ao atualizar o projeto.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Project> register(Project project, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/projects/register');

    final data = jsonEncode(project.toJson());
    try {
      final response = await http.post(
        url,
        headers: ApiService.getHeaders(authToken: token),

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
