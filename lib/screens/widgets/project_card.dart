import 'package:flutter/material.dart';
import '../project_details_screen.dart'; // Importe a nova tela

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String creationDate;
  final String summary;
  final String status;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.creationDate,
    required this.summary,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Adicionamos o InkWell para dar o efeito de clique e a função onTap
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProjectDetailsScreen(projectName: projectName),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        // Usamos Ink em vez de Container para o efeito de splash funcionar
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          // O conteúdo do Column permanece o mesmo
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nome do Projeto',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        projectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Data de Criação',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(creationDate, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            const Text(
              'Resumo:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              summary,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              'Situação:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              status,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
