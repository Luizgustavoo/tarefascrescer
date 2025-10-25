// FILE: lib/models/status.dart

import 'package:tarefas_projetocrescer/models/project.dart';

class ProjectCategoryModel {
  final int id;
  final String name;
  final List<Project>? project;

  ProjectCategoryModel({
    required this.id,
    required this.name,
    required this.project,
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
      return [];
    }

    return ProjectCategoryModel(
      id: json['id'],
      name: json['name'],
      project: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  // ## CORREÇÃO CRUCIAL ##
  // Esta parte ensina ao Dart que dois objetos Status são iguais se seus 'id's forem iguais.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
