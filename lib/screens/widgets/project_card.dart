import 'package:flutter/material.dart';
import '../project_details_screen.dart';

class ProjectCard extends StatelessWidget {
  final String projectName;
  final String creationDate;
  final String summary;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAttach;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.creationDate,
    required this.summary,
    required this.status,
    required this.onEdit,
    required this.onDelete,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
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
            // NOVA SEÇÃO DE BOTÕES
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(icon: Icons.edit_outlined, onPressed: onEdit),
                _actionButton(icon: Icons.delete_outline, onPressed: onDelete),
                _actionButton(icon: Icons.attach_file, onPressed: onAttach),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.grey[700]),
      splashRadius: 20,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
