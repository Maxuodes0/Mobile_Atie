import 'package:flutter/material.dart';

import '../data/models/page_meta.dart';
import '../data/models/task_item.dart';
import '../data/models/task_list_result.dart';
import 'tasks/widgets/task_card.dart';
import 'tasks/widgets/task_filters_row.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/error_banner.dart';
import '../widgets/app_page_header.dart';
import '../widgets/inline_loading_bar.dart';
import 'task_details_screen.dart';
import 'create_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const int _pageSize = 50;

  final _search = TextEditingController();

  bool _loading = true;
  bool _refreshing = false;
  bool _loadingMore = false;
  String? _error;

  String _statusFilter = 'all'; // all | pending | in_progress | done
  final Set<String> _updatingTaskIds = <String>{};

  List<TaskItem> _tasks = const <TaskItem>[];
  PageMeta _meta = const PageMeta(total: 0, limit: _pageSize, offset: 0);

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasMore => _tasks.length < _meta.total;

  Future<void> _load({required bool reset}) async {
    final initial = reset && _tasks.isEmpty;
    if (reset) {
      setState(() {
        _loading = initial;
        _refreshing = !initial;
        _loadingMore = false;
        _error = null;
        if (initial) {
          _tasks = const <TaskItem>[];
          _meta = const PageMeta(total: 0, limit: _pageSize, offset: 0);
        }
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _error = null;
      });
    }

    TaskListResult? result;
    String? error;

    try {
      result = await AppServices.tasks.listMyTasks(
        limit: _pageSize,
        offset: reset ? 0 : _tasks.length,
        view: 'table',
      );
    } catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      if (result != null) {
        final next = reset ? result.tasks : [..._tasks, ...result.tasks];
        _tasks = next;
        _meta = PageMeta(
          total: result.meta.total,
          limit: result.meta.limit,
          offset: next.length,
        );
      }
      _error = error;
      _loading = false;
      _refreshing = false;
      _loadingMore = false;
    });
  }

  List<TaskItem> get _visible {
    final q = _search.text.trim().toLowerCase();

    Iterable<TaskItem> items = _tasks;
    if (_statusFilter != 'all') {
      items = items.where((t) => t.status == _statusFilter);
    }
    if (q.isNotEmpty) {
      items = items.where((t) {
        final title = t.title.toLowerCase();
        final project = (t.projectName ?? '').toLowerCase();
        return title.contains(q) || project.contains(q);
      });
    }
    return items.toList();
  }

  Future<void> _markDone(TaskItem task) async {
    if (task.status == 'done') return;
    setState(() {
      _updatingTaskIds.add(task.id);
      _error = null;
    });

    try {
      final updated = await AppServices.tasks.updateStatus(
        taskId: task.id,
        status: 'done',
      );
      if (!mounted) return;
      setState(() {
        _tasks = _tasks.map((t) {
          if (t.id != task.id) return t;
          if ((updated.projectName ?? '').trim().isEmpty &&
              (t.projectName ?? '').trim().isNotEmpty) {
            return updated.copyWith(projectName: t.projectName);
          }
          return updated;
        }).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _updatingTaskIds.remove(task.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final items = _visible;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppPageHeader(
              title: 'المهام',
              subtitle: 'مهامي عبر المشاريع',
            ),
            InlineLoadingBar(visible: _refreshing),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final created = await Navigator.of(context).push<bool>(
                  MaterialPageRoute<bool>(
                    builder: (_) => const CreateTaskScreen(),
                  ),
                );
                if (!mounted) return;
                if (created == true) {
                  _load(reset: true);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F1115),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'إضافة مهمة',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            TaskFiltersRow(
              value: _statusFilter,
              onChanged: (v) => setState(() => _statusFilter = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'ابحث عن مهمة أو مشروع',
                prefixIcon: Icon(Icons.search, size: 20),
                prefixIconColor: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Text(
                'لا توجد مهام',
                style: TextStyle(color: AppTheme.muted, fontSize: 12),
              )
            else
              ...items.map(
                (t) => TaskCard(
                  task: t,
                  updating: _updatingTaskIds.contains(t.id),
                  onDone: () => _markDone(t),
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => TaskDetailsScreen(task: t),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
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
    );
  }
}
