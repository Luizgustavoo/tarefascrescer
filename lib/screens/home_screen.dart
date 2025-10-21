import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_project_modal.dart';
import 'widgets/home_header.dart';
import 'widgets/project_card.dart';
import 'widgets/recent_project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProjectProvider>(
        context,
        listen: false,
      ).fetchProjects(authProvider);
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

  @override
  Widget build(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();

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
                  : ListView(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: const Color(0XFFE134CA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
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
                          height: 110,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            children: const [
                              RecentProjectCard(
                                color: Color(0xFFE0F3FF),
                                projectName: 'App de Vendas',
                                creationDate: '10/09/2025',
                                status: 'Em Andamento',
                              ),
                              SizedBox(width: 16),
                              RecentProjectCard(
                                color: Color(0xFFFFF0E0),
                                projectName: 'Website Institucional',
                                creationDate: '05/09/2025',
                                status: 'Concluído',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            'Todos os Projetos',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          itemCount: projectProvider.projects.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                              onDelete: () {},
                              onAttach: () {},
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
