import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'api_service.dart';

class ProjectCategoryService {
  Future<List<ProjectCategoryModel>> list(String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-categories/list');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];
          return dataList
              .map((json) => ProjectCategoryModel.fromJson(json))
              .toList();
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

  Future<ProjectCategoryModel> register(String name, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-categories/register');
    try {
      final response = await http.post(
        url,
        headers: ApiService.getHeaders(authToken: token),
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data')) {
          return ProjectCategoryModel.fromJson(decodedBody['data']);
        } else {
          return ProjectCategoryModel.fromJson(decodedBody);
        }
      } else {
        throw Exception('Falha ao cadastrar a nova categoria de projeto.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ProjectCategoryModel> update(
    int categoryId,
    String newName,
    String token,
  ) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/project-categories/update/$categoryId',
    );
    try {
      final response = await http.put(
        url,
        headers: ApiService.getHeaders(authToken: token),
        body: jsonEncode({'name': newName}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data')) {
          return ProjectCategoryModel.fromJson(decodedBody['data']);
        } else {
          return ProjectCategoryModel.fromJson(decodedBody);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Falha ao atualizar a categoria.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int categoryId, String token) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/project-categories/delete/$categoryId',
    );
    try {
      final response = await http.delete(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else {
        String errorMessage = 'Falha ao deletar a categoria.';
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
}
