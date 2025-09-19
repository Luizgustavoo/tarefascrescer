import 'package:flutter/material.dart';
import 'widgets/add_project_modal.dart'; // Importe o novo modal
import 'widgets/bottom_nav_bar.dart';
import 'widgets/home_header.dart';
import 'widgets/project_card.dart';
import 'widgets/recent_project_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Função para abrir o modal de adicionar projeto
  void _showAddProjectModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o modal cresça sobre o teclado
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const AddProjectModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // A estrutura da Scaffold agora chama a função _showAddProjectModal
    return Scaffold(
      body: SafeArea(
        // O conteúdo do ListView permanece o mesmo
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          children: [
            // Cabeçalho
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: HomeHeader(),
            ),
            const SizedBox(height: 24),

            // Banner Roxo (Placeholder)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF6A3DE8),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Seção "Recentes movimentados"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Recentes movimentados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
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
                  SizedBox(width: 16),
                  RecentProjectCard(
                    color: Color(0xFFE0F3FF),
                    projectName: 'Sistema de RH',
                    creationDate: '01/09/2025',
                    status: 'Pausado',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Seção "Todos os Projetos"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Todos os Projetos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  ProjectCard(
                    projectName: 'Desenvolvimento App Mobile',
                    creationDate: '15/08/2025',
                    summary:
                        'Criação de um novo aplicativo para gerenciamento de tarefas e equipes...',
                    status: 'Em Andamento',
                  ),
                  SizedBox(height: 16),
                  ProjectCard(
                    projectName: 'Reforma do Escritório',
                    creationDate: '20/07/2025',
                    summary:
                        'Projeto de arquitetura e design de interiores para a nova sede da empresa.',
                    status: 'Concluído',
                  ),
                  SizedBox(height: 16),
                  ProjectCard(
                    projectName: 'Campanha de Marketing Q4',
                    creationDate: '01/07/2025',
                    summary:
                        'Planejamento e execução da campanha de marketing para o último trimestre.',
                    status: 'Planejamento',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectModal(context),
        backgroundColor: const Color(0xFF6A3DE8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
