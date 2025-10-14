class Status {
  final int id;
  final String name;

  Status({required this.id, required this.name});

  factory Status.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null) {
      throw FormatException("JSON inválido para ProjectStatus");
    }
    return Status(id: json['id'], name: json['name']);
  }

  // ADICIONADO: Sobrescrevendo o operador de igualdade (==) e o hashCode.
  // Isso ensina ao Dart como comparar duas instâncias de ProjectStatus.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Status && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
