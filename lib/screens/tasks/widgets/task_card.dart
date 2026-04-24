import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/task_item.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/task_status.dart';

class TaskCard extends StatelessWidget {
  final TaskItem task;
  final bool updating;
  final VoidCallback onDone;
  final VoidCallback onOpen;

  const TaskCard({
    super.key,
    required this.task,
    required this.updating,
    required this.onDone,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = taskStatusColor(task.status);
    final statusLabel = taskStatusLabel(task.status);
    final prioColor = taskPriorityColor(task.priority);
    final prioLabel = taskPriorityLabel(task.priority);

    final locale = Localizations.localeOf(context);
    final due = task.dueDate == null
        ? null
        : DateFormat.yMMMd(locale.toString()).format(task.dueDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsetsDirectional.only(top: 6, end: 12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.projectName ?? 'بدون مشروع',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 12,
                        ),
                      ),
                      if (due != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'الاستحقاق: $due',
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _TaskChip(label: statusLabel, color: statusColor),
                          const SizedBox(width: 8),
                          _TaskChip(
                            label: 'الأولوية: $prioLabel',
                            color: prioColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 42,
                  height: 42,
                  child: updating
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          onPressed: task.status == 'done' ? null : onDone,
                          icon: Icon(
                            task.status == 'done'
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: task.status == 'done'
                                ? statusColor
                                : AppTheme.muted,
                          ),
                          tooltip: 'إكمال',
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TaskChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacitySafe(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
