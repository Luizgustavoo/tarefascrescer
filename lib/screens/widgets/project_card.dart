import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/project_file_model.dart';
import 'package:tarefas_projetocrescer/screens/widgets/pdf_viewer_screen.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';
import '../project_details_screen.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAttach;
  final Color? backgroundColor;

  const ProjectCard({
    super.key,
    required this.project,
    this.onEdit,
    this.onDelete,
    this.onAttach,
    this.backgroundColor,
  });

  // --- Funções de Visualização (Adicionadas aqui) ---

  void _showImageDialog(BuildContext context, String imageUrl, String heroTag) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16.0),
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showPdfViewer(BuildContext context, ProjectFile file, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          fileUrl: file.fileUrl,
          heroTag: heroTag,
          fileName: file.originalName,
        ),
      ),
    );
  }

  void _openFile(BuildContext context, ProjectFile file) {
    final String heroTag = 'projectFileCardHero-${file.id}'; // Tag única
    if (file.fileType == 'image') {
      _showImageDialog(context, file.fileUrl, heroTag);
    } else if (file.extension == 'pdf') {
      _showPdfViewer(context, file, heroTag);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de arquivo não suportado.')),
      );
    }
  }
  // --- Fim das Funções de Visualização ---

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(project: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
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
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.folder_open_outlined),
              ],
            ),
            // ## SEÇÃO DE ANEXOS ADICIONADA ##
            if (project.files.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 6),
                    Text(
                      "Anexos (${project.files.length}):",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height:
                          32, // Altura fixa para a lista horizontal de chips
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: project.files.length,
                        itemBuilder: (ctx, index) {
                          final file = project.files[index];
                          final heroTag = 'projectFileCardHero-${file.id}';
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: InkWell(
                              onTap: () => _openFile(context, file),
                              child: Hero(
                                tag: heroTag,
                                child: Chip(
                                  avatar: Icon(
                                    file.icon,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    file.originalName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  backgroundColor: Colors.grey.shade200,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  labelPadding: const EdgeInsets.only(
                                    left: 4,
                                    right: 6,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // --- Fim da Seção de Anexos ---
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Data de Criação',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              Formatters.formatApiDate(project.presentationDate),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resumo:',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              project.observations,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Situação: ${project.status?.name ?? 'N/A'}',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  _actionButton(icon: Icons.edit, onPressed: onEdit!),
                if (onDelete != null)
                  _actionButton(icon: Icons.delete, onPressed: onDelete!),
                if (onAttach != null)
                  _actionButton(icon: Icons.attach_file, onPressed: onAttach!),
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
      icon: Icon(icon, color: Colors.grey[500]),
      splashRadius: 20,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
