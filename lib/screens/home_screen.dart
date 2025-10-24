import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/graph_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_file_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/providers/recent_task_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_project_modal.dart';
import 'package:tarefas_projetocrescer/screens/widgets/project_graph.dart';
import 'package:tarefas_projetocrescer/screens/widgets/recent_task_card.dart';
import 'widgets/home_header.dart';
import 'widgets/project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      final projectProvider = context.read<ProjectProvider>();
      final recentTaskProvider = context.read<RecentTaskProvider>();
      final graphProvider = context.read<GraphProvider>();
      final projectFileProvider = context.read<ProjectFileProvider>();

      recentTaskProvider.fetchRecentTasks(authProvider);
      graphProvider.fetchGraphData(authProvider);

      await projectProvider.fetchProjects(authProvider);

      if (mounted) {
        for (final project in projectProvider.projects) {
          if (project.id != null) {
            projectFileProvider.fetchFiles(project.id!, authProvider);
          }
        }
      }
    });
  }

  void _filterProjects(String query) {}

  void _showEditProjectModal(BuildContext context, Project projectToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: const Color(0xFFF8F8FA),

          child: AddProjectModal(projectToEdit: projectToEdit),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteProject(Project project) async {
    if (project.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o projeto "${project.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final projectProvider = context.read<ProjectProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await projectProvider.deleteProject(
        project.id!,
        authProvider,
      );

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              projectProvider.errorMessage ?? 'Falha ao excluir projeto.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadFile(Project project) async {
    if (project.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID do Projeto inválido.')));
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      File file = File(result.files.single.path!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviando ${result.files.single.name}...')),
      );

      final fileProvider = context.read<ProjectFileProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await fileProvider.uploadFile(
        project.id!,
        file,
        authProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo anexado ao projeto!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(fileProvider.uploadError ?? 'Falha no upload.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleção cancelada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final recentTaskProvider = context.watch<RecentTaskProvider>();
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding: const EdgeInsets.all(24.0),
              child: HomeHeader(onSearchChanged: _filterProjects),
            ),
            Expanded(
              child: projectProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );

                        await Future.wait([
                          Provider.of<ProjectProvider>(
                            context,
                            listen: false,
                          ).fetchProjects(authProvider),
                          Provider.of<GraphProvider>(
                            context,
                            listen: false,
                          ).fetchGraphData(authProvider),
                          Provider.of<RecentTaskProvider>(
                            context,
                            listen: false,
                          ).fetchRecentTasks(authProvider),
                        ]);
                      },
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        children: [
                          SizedBox(height: 230, child: ProjectValuesPieChart()),
                          const SizedBox(height: 32),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              'Recentes movimentados',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: recentTaskProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : recentTaskProvider.errorMessage != null
                                ? Center(
                                    child: Text(
                                      recentTaskProvider.errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  )
                                : recentTaskProvider.recentTasks.isEmpty
                                ? const Center(
                                    child: Text('Nenhuma tarefa recente.'),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24.0,
                                    ),
                                    itemCount:
                                        recentTaskProvider.recentTasks.length,
                                    itemBuilder: (context, index) {
                                      final task =
                                          recentTaskProvider.recentTasks[index];

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          right:
                                              index <
                                                  recentTaskProvider
                                                          .recentTasks
                                                          .length -
                                                      1
                                              ? 16.0
                                              : 0,
                                        ),
                                        child: RecentTaskCard(task: task),
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            itemCount: projectProvider.projects.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final project = projectProvider.projects[index];
                              final cardColor = index.isEven
                                  ? Colors.white
                                  : const Color(0xFFFFF1F3);
                              return ProjectCard(
                                project: project,
                                backgroundColor: cardColor,
                                onEdit: () =>
                                    _showEditProjectModal(context, project),
                                onDelete: () =>
                                    _confirmAndDeleteProject(project),
                                onAttach: () => _pickAndUploadFile(project),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
