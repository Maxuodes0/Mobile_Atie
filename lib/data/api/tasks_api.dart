import '../models/page_meta.dart';
import '../models/task_item.dart';
import '../models/task_list_result.dart';
import '../models/task_note.dart';
import '../models/task_notes_result.dart';
import 'api_client.dart';

class TasksApi {
  final ApiClient _api;

  TasksApi(this._api);

  Future<TaskItem> createTask({
    required String projectId,
    required Map<String, dynamic> data,
  }) async {
    final res = await _api.post(
      '/projects/$projectId/tasks',
      data: data,
    );

    if (res is Map) {
      final raw = res['task'];
      if (raw is Map<String, dynamic>) return TaskItem.fromJson(raw);
      if (raw is Map) return TaskItem.fromJson(Map<String, dynamic>.from(raw));
    }
    throw Exception('Unexpected create task response');
  }

  Future<TaskListResult> listMyTasks({
    int limit = 50,
    int offset = 0,
    String view = 'table',
  }) async {
    final res = await _api.get(
      '/tasks/mine',
      query: <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'view': view,
      },
    );

    if (res is Map) {
      final rawTasks = res['tasks'];
      final rawMeta = res['meta'];

      final tasks = rawTasks is List
          ? rawTasks
              .whereType<Map>()
              .map((t) => TaskItem.fromJson(Map<String, dynamic>.from(t)))
              .toList()
          : const <TaskItem>[];

      final meta = rawMeta is Map
          ? PageMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : PageMeta(total: tasks.length, limit: limit, offset: offset);

      return TaskListResult(tasks: tasks, meta: meta);
    }

    return TaskListResult(
      tasks: const <TaskItem>[],
      meta: PageMeta(total: 0, limit: limit, offset: offset),
    );
  }

  Future<TaskItem> updateStatus({
    required String taskId,
    required String status,
  }) async {
    final res = await _api.patch(
      '/tasks/$taskId',
      data: <String, dynamic>{'status': status},
    );

    if (res is Map) {
      final raw = res['task'];
      if (raw is Map<String, dynamic>) return TaskItem.fromJson(raw);
      if (raw is Map) {
        return TaskItem.fromJson(Map<String, dynamic>.from(raw));
      }
    }

    throw Exception('Unexpected update task response');
  }

  Future<TaskNotesResult> listTaskNotes({
    required String taskId,
    int limit = 50,
    int offset = 0,
  }) async {
    final res = await _api.get(
      '/tasks/$taskId/notes',
      query: <String, dynamic>{
        'limit': limit,
        'offset': offset,
      },
    );

    if (res is Map) {
      final rawNotes = res['notes'];
      final rawMeta = res['meta'];

      final notes = rawNotes is List
          ? rawNotes
              .whereType<Map>()
              .map((n) => TaskNote.fromJson(Map<String, dynamic>.from(n)))
              .toList()
          : const <TaskNote>[];

      final meta = rawMeta is Map
          ? PageMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : PageMeta(total: notes.length, limit: limit, offset: offset);

      return TaskNotesResult(notes: notes, meta: meta);
    }

    return TaskNotesResult(
      notes: const <TaskNote>[],
      meta: PageMeta(total: 0, limit: limit, offset: offset),
    );
  }

  Future<TaskNote> createTaskNote({
    required String taskId,
    required String body,
  }) async {
    final res = await _api.post(
      '/tasks/$taskId/notes',
      data: <String, dynamic>{'body': body},
    );

    if (res is Map) {
      final raw = res['note'] ?? res;
      if (raw is Map<String, dynamic>) return TaskNote.fromJson(raw);
      if (raw is Map) return TaskNote.fromJson(Map<String, dynamic>.from(raw));
    }

    throw Exception('Unexpected create note response');
  }
}
