import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/page_meta.dart';
import '../data/models/task_item.dart';
import '../data/models/task_note.dart';
import '../data/models/task_notes_result.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/task_status.dart';
import '../widgets/error_banner.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskItem task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  static const int _pageSize = 50;

  bool _loading = true;
  bool _loadingMore = false;
  bool _postingNote = false;
  String? _error;

  List<TaskNote> _notes = const <TaskNote>[];
  PageMeta _meta = const PageMeta(total: 0, limit: _pageSize, offset: 0);

  final TextEditingController _noteController = TextEditingController();

  bool get _hasMore => _notes.length < _meta.total;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _loadingMore = false;
        _error = null;
        _notes = const <TaskNote>[];
        _meta = const PageMeta(total: 0, limit: _pageSize, offset: 0);
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _error = null;
      });
    }

    TaskNotesResult? result;
    String? error;

    try {
      result = await AppServices.tasks.listTaskNotes(
        taskId: widget.task.id,
        limit: _pageSize,
        offset: reset ? 0 : _notes.length,
      );
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      if (result != null) {
        final next = reset ? result.notes : [..._notes, ...result.notes];
        _notes = next;
        _meta = PageMeta(
          total: result.meta.total,
          limit: result.meta.limit,
          offset: next.length,
        );
      }
      _error = error;
      _loading = false;
      _loadingMore = false;
    });
  }

  Future<void> _addNote() async {
    final body = _noteController.text.trim();
    if (body.isEmpty) return;

    setState(() {
      _postingNote = true;
      _error = null;
    });

    try {
      final note = await AppServices.tasks.createTaskNote(
        taskId: widget.task.id,
        body: body,
      );
      if (!mounted) return;
      setState(() {
        _noteController.clear();
        final nextNotes = [note, ..._notes];
        _notes = nextNotes;
        _meta = PageMeta(
          total: _meta.total + 1,
          limit: _meta.limit,
          offset: nextNotes.length,
        );
        _postingNote = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _postingNote = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final locale = Localizations.localeOf(context);

    final statusColor = taskStatusColor(task.status);
    final statusLabel = taskStatusLabel(task.status);
    final prioColor = taskPriorityColor(task.priority);
    final prioLabel = taskPriorityLabel(task.priority);

    final due = task.dueDate == null
        ? null
        : DateFormat.yMMMd(locale.toString()).format(task.dueDate!);

    if (_loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المهمة'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(reset: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.projectName ?? 'بدون مشروع',
                      style:
                          const TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                    if (due != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'الاستحقاق: $due',
                        style: const TextStyle(
                            color: AppTheme.muted, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(label: statusLabel, color: statusColor),
                        _Pill(
                          label: 'الأولوية: $prioLabel',
                          color: prioColor,
                        ),
                      ],
                    ),
                    if ((task.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(color: AppTheme.border, height: 1),
                      const SizedBox(height: 14),
                      Text(
                        task.description!.trim(),
                        style: const TextStyle(height: 1.35),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'الملاحظات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    '${_meta.total}',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إضافة ملاحظة',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 5,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        hintText: 'اكتب ملاحظة...',
                        filled: true,
                        fillColor: AppTheme.ink.withOpacitySafe(0.03),
                        contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            12, 12, 12, 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppTheme.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: AppTheme.ink, width: 1.4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _postingNote ? null : _addNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: _postingNote
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'إرسال',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              if (_notes.isEmpty)
                const Text(
                  'لا توجد ملاحظات',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12),
                )
              else
                ..._notes.map((n) => _NoteCard(note: n)),
              if (_hasMore) ...[
                const SizedBox(height: 8),
                _loadingMore
                    ? const Center(child: CircularProgressIndicator())
                    : OutlinedButton(
                        onPressed: () => _load(reset: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'تحميل المزيد',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F1115),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({
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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final TaskNote note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final created = note.createdAt.millisecondsSinceEpoch == 0
        ? null
        : DateFormat.yMMMd(locale.toString()).add_jm().format(note.createdAt);

    final author = (note.authorName ?? '').trim().isEmpty
        ? 'مستخدم'
        : note.authorName!.trim();
    final initial = author.isNotEmpty ? author.characters.first : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.ink.withOpacitySafe(0.06),
            foregroundColor: AppTheme.ink,
            child: Text(
              initial,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        author,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (created != null)
                      Text(
                        created,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.body.trim().isEmpty ? '-' : note.body.trim(),
                  style: const TextStyle(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
