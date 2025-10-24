// FILE: lib/services/project_file_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:tarefas_projetocrescer/models/project_file_model.dart'; // Ajuste o import
import 'api_service.dart';

class ProjectFileService {
  // --- Lista arquivos de um PROJETO específico ---
  Future<List<ProjectFile>> listFiles(int projectId, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-files/$projectId');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        // Assume que a API retorna a lista diretamente (sem 'data')
        final List<dynamic> dataList = jsonDecode(response.body);
        return dataList.map((json) => ProjectFile.fromJson(json)).toList();

        /* // Se retornar dentro de 'data', use esta lógica
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];
          return dataList.map((json) => ProjectFile.fromJson(json)).toList();
        } else {
          throw Exception('Formato de resposta da API de arquivos de projeto inesperado.');
        }
        */
      } else {
        throw Exception('Falha ao carregar arquivos do projeto.');
      }
    } catch (e) {
      print("Erro em ProjectFileService.listFiles: $e");
      rethrow;
    }
  }

  // --- Faz upload de um arquivo para um PROJETO específico ---
  Future<ProjectFile> upload(int projectId, File file, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-files/upload');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiService.getHeaders(authToken: token));

      // Adiciona o project_id
      request.fields['project_id'] = projectId.toString();

      // Adiciona o arquivo
      var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file', // Chave que a API espera
        stream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data')) {
          return ProjectFile.fromJson(decodedBody['data']);
        } else {
          throw Exception(
            'Resposta da API de upload (project file) inesperada.',
          );
        }
      } else {
        String errorMessage = 'Falha no upload do arquivo.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
            if (errorData['errors'] != null)
              errorMessage += '\n${errorData['errors']}';
          } catch (_) {}
        }
        print(
          "Erro Upload Project File: ${response.statusCode} - ${response.body}",
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erro em ProjectFileService.upload: $e");
      rethrow;
    }
  }
}
