import 'page_meta.dart';
import 'task_item.dart';

class TaskListResult {
  final List<TaskItem> tasks;
  final PageMeta meta;

  const TaskListResult({
    required this.tasks,
    required this.meta,
  });
}
