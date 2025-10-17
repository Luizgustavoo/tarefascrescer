import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'widgets/home_header.dart';
import 'widgets/project_card.dart';
import 'widgets/recent_project_card.dart';

class HomeScreen extends StatefulWidget {
  // A Key é opcional agora, pois não precisamos mais chamar o método 'addProject' de fora.
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos Future.microtask para garantir que o context esteja disponível.
    // Pedimos ao provider para carregar os projetos assim que a tela for construída.
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<ProjectProvider>(
        context,
        listen: false,
      ).fetchProjects(authProvider);
    });
  }

  // A função de filtro agora pode ser simplificada ou movida para o provider.
  // Por enquanto, vamos filtrar a lista que recebemos do provider.
  void _filterProjects(String query) {
    // A lógica de filtro pode ser implementada aqui ou no provider no futuro.
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' para que a tela reconstrua automaticamente quando a lista de projetos mudar.
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
              // Mostra um indicador de carregamento enquanto busca os dados
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
                          // Usa a lista de projetos diretamente do provider
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
                              onEdit: () {},
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
