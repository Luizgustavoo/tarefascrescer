class ApiService {
  static const String baseUrl =
      'http://api.tasks.projetocrescerarapongas.org.br/api';

  // Helper que cria os headers. Se um token for fornecido, ele o adiciona.
  static Map<String, String> getHeaders({String? authToken}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }
}
