// FILE: lib/models/project_model.dart

import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/user.dart';
import 'package:tarefas_projetocrescer/models/project_file_model.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart'; // Importe a Categoria

class Project {
  final int? id;
  final String name;
  final String fiscalResponsible;
  final Status? status;
  final int statusId;
  final ProjectCategoryModel? category; // Adicione o objeto Categoria
  final int categoryId; // Mantenha o ID para o cadastro
  final int createdBy;
  final User? createdByUser;
  final String presentationDate;
  final double presentedValue;
  final String approvalDate;
  final double? approvedValue;
  final String accountabilityDate;
  final String collectionStartDate;
  final String collectionEndDate;
  final double? totalCollected;
  final String executionStartDate;
  final String executionEndDate;
  final String observations;
  final String? bankAccount;
  final String color;
  final List<ProjectFile> files;

  Project({
    this.id,
    required this.name,
    required this.fiscalResponsible,
    this.status,
    required this.statusId,
    this.category,
    required this.categoryId,
    required this.createdBy,
    this.createdByUser,
    required this.presentationDate,
    required this.presentedValue,
    required this.approvalDate,
    this.approvedValue,
    required this.accountabilityDate,
    required this.collectionStartDate,
    required this.collectionEndDate,
    this.totalCollected,
    required this.executionStartDate,
    required this.executionEndDate,
    required this.observations,
    required this.color,
    this.files = const [],
    this.bankAccount,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    List<ProjectFile> parseFiles(dynamic fileList) {
      if (fileList != null && fileList is List) {
        return fileList
            .map((fileJson) => ProjectFile.fromJson(fileJson))
            .toList();
      }
      return [];
    }

    // ## CORREÇÃO PRINCIPAL AQUI ##
    // Lógica segura para extrair o usuário de 'created_by'
    User? userObject;
    int createdById = 0;
    // O JSON da API agora envia o objeto User dentro de 'created_by'
    if (json['created_by'] != null &&
        json['created_by'] is Map<String, dynamic>) {
      userObject = User.fromJson(json['created_by']);
      createdById = userObject.id;
    } else if (json['created_by'] is int) {
      // Fallback caso a API envie só o ID
      createdById = json['created_by'];
    }

    return Project(
      id: json['id'],
      name: json['name'] ?? '',
      fiscalResponsible: json['fiscal_responsible'] ?? '',
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      statusId: json['status_id'] ?? 0,

      // Usa os valores extraídos com segurança
      createdBy: createdById,
      createdByUser: userObject,

      category: json['category'] != null
          ? ProjectCategoryModel.fromJson(json['category'])
          : null,
      categoryId: json['project_category_id'] ?? 0,
      presentationDate: json['presentation_date'] ?? '',
      presentedValue: parseToDouble(json['presented_value']) ?? 0.0,
      approvalDate: json['approval_date'] ?? '',
      bankAccount: json['bank_account'] ?? '',
      approvedValue: parseToDouble(json['approved_value']),
      accountabilityDate: json['accountability_date'] ?? '',
      collectionStartDate: json['collection_start_date'] ?? '',
      collectionEndDate: json['collection_end_date'] ?? '',
      totalCollected: parseToDouble(json['total_collected']),
      executionStartDate: json['execution_start_date'] ?? '',
      executionEndDate: json['execution_end_date'] ?? '',
      observations: json['observations'] ?? '',
      color: json['color'] ?? '#FFFFFF',
      files: parseFiles(json['files']),
    );
  }

  // O toJson permanece o mesmo
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fiscal_responsible': fiscalResponsible,
      'status_id': statusId,
      'project_category_id':
          categoryId, // Certifique-se de que o model no add_project_modal envie isso
      'presentation_date': presentationDate,
      'presented_value': presentedValue,
      'approval_date': approvalDate,
      'approved_value': approvedValue,
      'accountability_date': accountabilityDate,
      'collection_start_date': collectionStartDate,
      'collection_end_date': collectionEndDate,
      'total_collected': totalCollected,
      'execution_start_date': executionStartDate,
      'execution_end_date': executionEndDate,
      'observations': observations,
      'created_by': createdBy,
      'color': color,
      'bank_account': bankAccount,
    };
  }

  // copyWith (deve ser atualizado)
  Project copyWith({
    int? id,
    String? name,
    String? fiscalResponsible,
    Status? status, // Espera um objeto Status?
    int? statusId,
    ProjectCategoryModel? category, // Espera um objeto ProjectCategoryModel?
    int? categoryId,
    int? createdBy,
    User? createdByUser,
    String? presentationDate,
    double? presentedValue,
    String? approvalDate,
    double? approvedValue,
    String? accountabilityDate,
    String? collectionStartDate,
    String? collectionEndDate,
    double? totalCollected,
    String? executionStartDate,
    String? executionEndDate,
    String? observations,
    String? color,
    String? bankAccount,
    List<ProjectFile>? files,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      fiscalResponsible: fiscalResponsible ?? this.fiscalResponsible,
      status: status ?? this.status, // Usa o objeto diretamente
      statusId: statusId ?? this.statusId,
      category: category ?? this.category, // Usa o objeto diretamente
      categoryId: categoryId ?? this.categoryId,
      createdBy: createdBy ?? this.createdBy,
      createdByUser: createdByUser ?? this.createdByUser,
      presentationDate: presentationDate ?? this.presentationDate,
      presentedValue: presentedValue ?? this.presentedValue,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedValue: approvedValue ?? this.approvedValue,
      accountabilityDate: accountabilityDate ?? this.accountabilityDate,
      collectionStartDate: collectionStartDate ?? this.collectionStartDate,
      collectionEndDate: collectionEndDate ?? this.collectionEndDate,
      totalCollected: totalCollected ?? this.totalCollected,
      executionStartDate: executionStartDate ?? this.executionStartDate,
      executionEndDate: executionEndDate ?? this.executionEndDate,
      observations: observations ?? this.observations,
      color: color ?? this.color,
      bankAccount: bankAccount ?? this.bankAccount,
      files: files ?? this.files,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project && runtimeType == other.runtimeType && id == other.id; // Compara pelo ID

  @override
  int get hashCode => id.hashCode;
}
