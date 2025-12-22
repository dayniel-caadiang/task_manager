import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          task.completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.completed ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(
          task.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text('User ${task.userId}'),
              const SizedBox(width: 12),
              Icon(
                Icons.tag,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text('ID: ${task.id}'),
            ],
          ),
        ),
        trailing: Chip(
          label: Text(
            task.completed ? 'Done' : 'Pending',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: task.completed ? Colors.green[100] : Colors.orange[100],
          side: BorderSide.none,
        ),
        onTap: onTap,
      ),
    );
  }
}
