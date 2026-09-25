import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_filters.dart';
import 'finance_project_detail_screen.dart';
import 'finance_results.dart';
import 'finance_ui.dart';

class FinanceCollectionsScreen extends StatefulWidget {
  final FinanceQuery query;
  const FinanceCollectionsScreen({super.key, required this.query});

  @override
  State<FinanceCollectionsScreen> createState() =>
      _FinanceCollectionsScreenState();
}

class _FinanceCollectionsScreenState extends State<FinanceCollectionsScreen> {
  late FinanceQuery _query;
  FinanceDataPage? _data;
  bool _loading = true;
  String? _error;
  int _ticket = 0;

  bool get _canManage {
    final role = AppServices.session.user.value?.role.toUpperCase();
    final roleAllowed = role == 'ADMIN' || role == 'PROGRAM_MANAGER';
    return roleAllowed &&
        (AppServices.session.access.value?.actions
                .contains('projects.collections.manage') ??
            false);
  }

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    AppServices.session.access.addListener(_accessChanged);
    _load();
  }

  void _accessChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    AppServices.session.access.removeListener(_accessChanged);
    super.dispose();
  }

  Future<void> _load() async {
    final ticket = ++_ticket;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await AppServices.finance.getCollections(_query);
      if (!mounted || ticket != _ticket) return;
      setState(() {
        _data = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || ticket != _ticket) return;
      setState(() {
        _data = null;
        _error = error.toString();
        _loading = false;
      });
    }
  }

  void _change(FinanceQuery query) {
    setState(() => _query = query);
    _load();
  }

  Future<void> _filters() async {
    final changed = await showFinanceFilters(context, _query);
    if (changed != null) _change(changed);
  }

  Future<void> _create() async {
    if (!_canManage) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.pageBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) =>
          _CreateCollectionSheet(initialProjectId: _query.projectId),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    if (!_canManage) return;
    final projectId = row['projectId']?.toString();
    final collectionId = (row['collectionId'] ?? row['id'])?.toString();
    if (projectId == null || collectionId == null) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  context.tr(en: 'Delete collection?', ar: 'حذف التحصيل؟')),
              content: Text(context.tr(
                  en: 'This action cannot be undone.',
                  ar: 'لا يمكن التراجع عن هذا الإجراء.')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(context.tr(en: 'Cancel', ar: 'إلغاء'))),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(context.tr(en: 'Delete', ar: 'حذف'))),
              ],
            ));
    if (confirmed != true) return;
    try {
      await AppServices.finance.deleteCollection(projectId, collectionId);
      _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.toString()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
            title: Text(context.tr(en: 'Collections', ar: 'التحصيلات')),
            actions: [
              if (_canManage)
                IconButton(
                  key: const ValueKey('finance-add-collection'),
                  tooltip:
                      context.tr(en: 'Record collection', ar: 'تسجيل تحصيل'),
                  onPressed: _create,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                )
            ]),
        body: SafeArea(
            child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 40),
            children: [
              FinanceQueryBar(
                initialSearch: _query.search,
                onSearch: (value) => _change(value.trim().isEmpty
                    ? _query.copyWith(clearSearch: true, page: 1)
                    : _query.copyWith(search: value.trim(), page: 1)),
                onFilters: _filters,
              ),
              const SizedBox(height: 14),
              FinanceResults(
                data: _data,
                error: _error,
                loading: _loading,
                onRetry: _load,
                onPage: (page) => _change(_query.copyWith(page: page)),
                header: _data == null
                    ? null
                    : FinanceSurface(
                        color: AppTheme.dashboardMint,
                        child: FinanceLabelValue(
                          label: context.tr(
                              en: 'Filtered collected total',
                              ar: 'إجمالي التحصيلات المفلترة'),
                          value: financeMoney(_data!.filteredTotal),
                          prominent: true,
                        ),
                      ),
                rowBuilder: (context, row) => FinanceSurface(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(
                                  financeField(row, ['projectName', 'name']),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16))),
                          if (_canManage)
                            IconButton(
                              tooltip: context.tr(
                                  en: 'Delete collection', ar: 'حذف التحصيل'),
                              onPressed: () => _delete(row),
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent),
                            ),
                        ]),
                        Text(financeField(row, ['clientName']),
                            style: const TextStyle(
                                color: AppTheme.muted, fontSize: 12)),
                        const SizedBox(height: 6),
                        FinanceLabelValue(
                            label: context.tr(en: 'Amount', ar: 'المبلغ'),
                            value: financeMoney(
                                row['collectedAmount'] ?? row['amount']),
                            prominent: true),
                        FinanceLabelValue(
                            label: context.tr(
                                en: 'Collected on', ar: 'تاريخ التحصيل'),
                            value: financeDate(row['collectedDate'])),
                        if (row['referenceNumber'] != null)
                          FinanceLabelValue(
                              label: context.tr(en: 'Reference', ar: 'المرجع'),
                              value: row['referenceNumber'].toString()),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton.icon(
                            onPressed: row['projectId'] == null
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                          builder: (_) =>
                                              FinanceProjectDetailScreen(
                                                projectId:
                                                    row['projectId'].toString(),
                                              )),
                                    ),
                            icon: const Icon(Icons.arrow_outward_rounded,
                                size: 17),
                            label: Text(context.tr(
                                en: 'Project finance', ar: 'مالية المشروع')),
                          ),
                        ),
                      ]),
                ),
              ),
            ],
          ),
        )),
      );
}

class _CreateCollectionSheet extends StatefulWidget {
  final String? initialProjectId;
  const _CreateCollectionSheet({required this.initialProjectId});

  @override
  State<_CreateCollectionSheet> createState() => _CreateCollectionSheetState();
}

class _CreateCollectionSheetState extends State<_CreateCollectionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  late Future<List<(String id, String name)>> _projects;
  String? _projectId;
  String? _date;
  String _method = 'BANK_TRANSFER';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _projectId = widget.initialProjectId;
    _projects = _loadProjects();
  }

  Future<List<(String id, String name)>> _loadProjects() async {
    const pageSize = 200;
    final results = <(String id, String name)>[];
    var offset = 0;
    while (true) {
      final page = await AppServices.projects
          .listProjectsPage(limit: pageSize, offset: offset, view: 'select');
      results
          .addAll(page.projects.map((project) => (project.id, project.name)));
      offset += page.projects.length;
      if (page.projects.isEmpty ||
          offset >= page.meta.total ||
          page.projects.length < pageSize) {
        break;
      }
    }
    return results;
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    setState(() => _date =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _projectId == null ||
        _date == null) {
      setState(() => _error = context.tr(
          en: 'Project and collection date are required.',
          ar: 'المشروع وتاريخ التحصيل مطلوبان.'));
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AppServices.finance.createCollection(_projectId!, {
        'collectedAmount': _amount.text.trim(),
        'collectedDate': _date,
        'method': _method,
        if (_reference.text.trim().isNotEmpty)
          'referenceNumber': _reference.text.trim(),
        if (_notes.text.trim().isNotEmpty) 'notes': _notes.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr(en: 'Record collection', ar: 'تسجيل تحصيل'),
                        style: const TextStyle(
                            fontSize: 23, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 16),
                    FutureBuilder<List<(String id, String name)>>(
                        future: _projects,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return FinanceErrorState(
                              onRetry: () =>
                                  setState(() => _projects = _loadProjects()),
                              message: snapshot.error.toString(),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          final rows = snapshot.data!;
                          return DropdownButtonFormField<String>(
                            initialValue:
                                rows.any((row) => row.$1 == _projectId)
                                    ? _projectId
                                    : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                                labelText:
                                    context.tr(en: 'Project', ar: 'المشروع')),
                            items: rows
                                .map((row) => DropdownMenuItem(
                                    value: row.$1,
                                    child: Text(row.$2,
                                        overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _projectId = value),
                          );
                        }),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: context.tr(
                              en: 'Amount (SAR)', ar: 'المبلغ (ريال)')),
                      validator: (value) => RegExp(
                                  r'^(?!0+(?:\.0+)?$)\d+(?:\.\d{1,2})?$')
                              .hasMatch(value?.trim() ?? '')
                          ? null
                          : context.tr(
                              en: 'Enter a positive amount with up to 2 decimals.',
                              ar: 'أدخل مبلغًا موجبًا حتى منزلتين عشريتين.'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(_date == null
                            ? context.tr(
                                en: 'Collection date', ar: 'تاريخ التحصيل')
                            : financeDate(_date))),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _method,
                      decoration: InputDecoration(
                          labelText: context.tr(
                              en: 'Payment method', ar: 'طريقة الدفع')),
                      items: [
                        (
                          'BANK_TRANSFER',
                          context.tr(en: 'Bank transfer', ar: 'تحويل بنكي')
                        ),
                        ('CHECK', context.tr(en: 'Check', ar: 'شيك')),
                        ('CASH', context.tr(en: 'Cash', ar: 'نقدًا')),
                        (
                          'CREDIT_CARD',
                          context.tr(en: 'Credit card', ar: 'بطاقة ائتمانية')
                        ),
                        ('OTHER', context.tr(en: 'Other', ar: 'أخرى')),
                      ]
                          .map((entry) => DropdownMenuItem(
                              value: entry.$1, child: Text(entry.$2)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _method = value ?? 'BANK_TRANSFER'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _reference,
                        decoration: InputDecoration(
                            labelText: context.tr(
                                en: 'Reference (optional)',
                                ar: 'المرجع (اختياري)'))),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _notes,
                        decoration: InputDecoration(
                            labelText: context.tr(
                                en: 'Notes (optional)',
                                ar: 'ملاحظات (اختياري)'))),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(color: Colors.redAccent)),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const CircularProgressIndicator()
                              : Text(context.tr(
                                  en: 'Save collection', ar: 'حفظ التحصيل')),
                        )),
                  ]),
            )),
      ));
}
