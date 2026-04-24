import 'page_meta.dart';
import 'task_note.dart';

class TaskNotesResult {
  final List<TaskNote> notes;
  final PageMeta meta;

  const TaskNotesResult({
    required this.notes,
    required this.meta,
  });
}
