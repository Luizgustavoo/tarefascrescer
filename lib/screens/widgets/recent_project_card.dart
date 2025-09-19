import 'package:flutter/material.dart';

class RecentProjectCard extends StatelessWidget {
  final Color color;
  final String projectName;
  final String creationDate;
  final String status;

  const RecentProjectCard({
    super.key,
    required this.color,
    required this.projectName,
    required this.creationDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            projectName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            creationDate,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          Text(status, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
        ],
      ),
    );
  }
}
