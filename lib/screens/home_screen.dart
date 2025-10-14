import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'widgets/home_header.dart';
import 'widgets/project_card.dart';
import 'widgets/recent_project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final List<Project> _allProjects = [
    Project(
      name: 'Desenvolvimento App Mobile',
      status: 'Em Execução',
      dataApresentacao: '15/02/2025',
      dataAprovacao: '01/03/2025',
      dataPrestacaoContas: '30/12/2025',
      finalCaptacao: '30/05/2025',
      totalCaptado: 50000.0,
      inicioExecucao: '01/06/2025',
      fimExecucao: '20/12/2025',
      contempla:
          'Jovens de 15 a 18 anos da comunidade local, oferecendo cursos de programação e design.',
      observacoes: 'Maria Silva - (11) 98765-4321\nJoão Costa - Coordenador',
      responsavelFiscal: 'Pola Adriana',
    ),
    Project(
      name: 'Reforma do Escritório',
      status: 'Concluído',
      dataApresentacao: '10/01/2025',
      dataAprovacao: '20/01/2025',
      dataPrestacaoContas: '15/06/2025',
      finalCaptacao: '28/02/2025',
      totalCaptado: 120000.0,
      inicioExecucao: '01/03/2025',
      fimExecucao: '30/05/2025',
      contempla:
          'Todos os colaboradores da empresa, com um ambiente de trabalho mais moderno e ergonômico.',
      observacoes: 'Carlos Pereira - (21) 91234-5678',
      responsavelFiscal: 'Ana Paula',
    ),
  ];
  late List<Project> _filteredProjects;

  @override
  void initState() {
    super.initState();
    _filteredProjects = _allProjects;
  }

  void addProject(Project project) {
    setState(() {
      _allProjects.insert(0, project);
      _filteredProjects = _allProjects;
    });
  }

  void _filterProjects(String query) {
    setState(() {
      _filteredProjects = _allProjects
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView(
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    itemCount: _filteredProjects.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
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
