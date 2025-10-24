// FILE: lib/screens/widgets/recent_task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tarefas_projetocrescer/models/task.dart'; // Ajuste o import
import 'package:tarefas_projetocrescer/utils/formatters.dart'; // Ajuste o import

class RecentTaskCard extends StatelessWidget {
  final Task task;

  const RecentTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final cardColor = Formatters.colorFromHex(
      task.color,
      defaultColor: Colors.blueGrey.shade50,
    );
    // Decide a cor do texto com base na cor de fundo para melhor contraste
    final textColor = cardColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Container(
      width:
          MediaQuery.sizeOf(context).height /
          4, // Largura do card na lista horizontal
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Sombra suave opcional
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui o espaço
        children: [
          // Descrição da Tarefa (Nome)
          Text(
            task.description,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
            maxLines: 2, // Limita a 2 linhas
            overflow: TextOverflow.ellipsis, // Adiciona "..." se for maior
          ),
          // Data Agendada
          Text(
            DateFormat('dd/MM/yyyy').format(task.scheduledAt),
            style: TextStyle(
              color: textColor.withOpacity(0.8), // Levemente transparente
              fontSize: 12,
            ),
          ),
          // Status da Tarefa
          Text(
            task.status?.name ?? 'N/A',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
