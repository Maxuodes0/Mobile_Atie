import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../data/api/api_exception.dart';
import '../data/models/org_user.dart';
import '../data/models/org_users_result.dart';
import '../data/models/project_summary.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import 'create_task/widgets/create_task_project_picker_sheet.dart';
import 'create_task/widgets/create_task_select_tile.dart';
import 'create_task/widgets/create_task_user_picker_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/primary_button.dart';

const int _orgUsersPageSize = 50;

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();

  bool _bootLoading = true;
  bool _submitting = false;
  String? _error;

  List<ProjectSummary> _projects = const [];
  List<OrgUser> _orgUsers = const [];
  int _orgUsersTotal = 0;

  ProjectSummary? _selectedProject;
  OrgUser? _selectedAssignee;
  String _priority = 'medium'; // low | medium | high
  String _section = 'TODO'; // BACKLOG | TODO | IN_PROGRESS | IN_REVIEW | DONE
  DateTime? _dueDate;

  bool get _canSubmit {
    return !_submitting &&
        _selectedProject != null &&
        _title.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadInitial();
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _bootLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        AppServices.projects.listProjects(limit: 200, offset: 0),
        AppServices.users.listMyOrganizationUsers(
          limit: _orgUsersPageSize,
          offset: 0,
          view: 'basic',
        ),
      ]);

      final projects = results[0] as List<ProjectSummary>;
      final usersResult = results[1] as OrgUsersResult;

      if (!mounted) return;
      setState(() {
        _projects = projects;
        _orgUsers = usersResult.users;
        _orgUsersTotal = usersResult.meta.total;
        _bootLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _bootLoading = false;
      });
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final projectId = _selectedProject!.id;
      final payload = <String, dynamic>{
        'title': _title.text.trim(),
        'description':
            _description.text.trim().isEmpty ? null : _description.text.trim(),
        'priority': _priority,
        'section': _section,
        if (_selectedAssignee != null) 'assigneeId': _selectedAssignee!.id,
        if (_dueDate != null) 'dueDate': _dueDate!.toIso8601String(),
      }..removeWhere((_, v) => v == null);

      await AppServices.tasks.createTask(projectId: projectId, data: payload);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _selectProject() async {
    final selected = await showModalBottomSheet<ProjectSummary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateTaskProjectPickerSheet(items: _projects),
    );
    if (!mounted || selected == null) return;
    setState(() => _selectedProject = selected);
  }

  Future<void> _selectAssignee() async {
    final selected = await showModalBottomSheet<OrgUser?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateTaskUserPickerSheet(
        initialItems: _orgUsers,
        initialTotal: _orgUsersTotal,
        pageSize: _orgUsersPageSize,
      ),
    );
    if (!mounted) return;
    setState(() => _selectedAssignee = selected);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final dueText = _dueDate == null
        ? '—'
        : intl.DateFormat.yMMMd(locale.toString()).format(_dueDate!.toLocal());

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مهمة')),
      body: SafeArea(
        child: _bootLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null) ...[
                    ErrorBanner(message: _error!),
                    const SizedBox(height: 12),
                  ],
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. اختر المشروع',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CreateTaskSelectTile(
                          title: _selectedProject?.name ?? 'اختر مشروع',
                          subtitle: _selectedProject?.clientName,
                          onTap: _selectProject,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '2. اختر الشخص (اختياري)',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        CreateTaskSelectTile(
                          title: (_selectedAssignee?.name ?? '').trim().isEmpty
                              ? 'بدون إسناد'
                              : _selectedAssignee!.name,
                          subtitle:
                              (_selectedAssignee?.email ?? '').trim().isEmpty
                                  ? null
                                  : _selectedAssignee!.email,
                          onTap: _selectAssignee,
                          trailing: _selectedAssignee == null
                              ? null
                              : IconButton(
                                  onPressed: () =>
                                      setState(() => _selectedAssignee = null),
                                  icon: const Icon(Icons.close),
                                  tooltip: 'إزالة',
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '3. تفاصيل المهمة',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _title,
                          decoration: const InputDecoration(
                            labelText: 'عنوان المهمة',
                            hintText: 'مثال: تجهيز عرض السعر',
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _description,
                          decoration: const InputDecoration(
                            labelText: 'الوصف (اختياري)',
                          ),
                          minLines: 2,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _priority,
                                decoration: const InputDecoration(
                                    labelText: 'الأولوية'),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'low',
                                    child: Text('منخفضة'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'medium',
                                    child: Text('متوسطة'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'high',
                                    child: Text('عالية'),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () => _priority = v ?? 'medium',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _section,
                                decoration: const InputDecoration(
                                  labelText: 'المرحلة',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'BACKLOG',
                                    child: Text('Backlog'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'TODO',
                                    child: Text('To do'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'IN_PROGRESS',
                                    child: Text('In progress'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'IN_REVIEW',
                                    child: Text('In review'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DONE',
                                    child: Text('Done'),
                                  ),
                                ],
                                onChanged: (v) => setState(
                                  () => _section = v ?? 'TODO',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CreateTaskSelectTile(
                          title: 'تاريخ الاستحقاق',
                          subtitle: dueText,
                          onTap: _pickDueDate,
                          trailing: _dueDate == null
                              ? null
                              : IconButton(
                                  onPressed: () =>
                                      setState(() => _dueDate = null),
                                  icon: const Icon(Icons.close),
                                  tooltip: 'إزالة',
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'إضافة المهمة',
                    loading: _submitting,
                    onPressed: _canSubmit ? _submit : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }
}
