import 'package:tarefas_projetocrescer/models/project.dart';

class ProjectCategoryModel {
  final int id;
  final String name;
  final List<Project> projects;

  ProjectCategoryModel({
    required this.id,
    required this.name,
    required this.projects,
  });

  factory ProjectCategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null || json['name'] == null) {
      throw FormatException("JSON inválido para ProjectCategoryModel");
    }

    List<Project> parseProjects(dynamic projectList) {
      if (projectList != null && projectList is List) {
        return projectList
            .map((projectJson) => Project.fromJson(projectJson))
            .toList();
      }
      return []; // Retorna lista vazia se 'projects' for nulo
    }

    // ## CORREÇÃO AQUI ##
    return ProjectCategoryModel(
      id: json['id'],
      name: json['name'],
      // Chama a função de parse para a chave 'projects' da API
      projects: parseProjects(json['projects']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  ProjectCategoryModel copyWith({
    int? id,
    String? name,
    List<Project>? projects,
  }) {
    return ProjectCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      projects: projects ?? this.projects,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
