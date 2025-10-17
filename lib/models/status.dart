// FILE: lib/models/status.dart

class Status {
  final int id;
  final String name;

  Status({required this.id, required this.name});

  factory Status.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null) {
      throw FormatException("JSON inválido para Status");
    }
    return Status(id: json['id'], name: json['name']);
  }

  // ## CORREÇÃO CRUCIAL ##
  // Esta parte ensina ao Dart que dois objetos Status são iguais se seus 'id's forem iguais.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
