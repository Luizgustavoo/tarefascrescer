class ApiService {
  // static const String baseUrl =
  //     'http://api.tasks.projetocrescerarapongas.org.br/api';

  static const String baseUrl = 'http://192.168.0.103:8000/api';

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
