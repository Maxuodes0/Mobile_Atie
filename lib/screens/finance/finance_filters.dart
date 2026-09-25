import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'finance_ui.dart';

class _FilterOption {
  final String id;
  final String name;
  const _FilterOption(this.id, this.name);
}

class _FilterOptions {
  final List<_FilterOption> clients;
  final List<_FilterOption> operators;
  final List<_FilterOption> projects;
  const _FilterOptions(this.clients, this.operators, this.projects);
}

Future<_FilterOptions> _loadOptions() async {
  Future<List<_FilterOption>> clients() async {
    try {
      final rows = await AppServices.clients
          .listAllClients(cacheTtl: const Duration(minutes: 5));
      return rows.map((row) => _FilterOption(row.id, row.name)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<_FilterOption>> operators() async {
    try {
      const pageSize = 200;
      final options = <_FilterOption>[];
      var offset = 0;
      while (true) {
        final response = await AppServices.api.get(
          '/operating-companies',
          query: {'limit': pageSize, 'offset': offset},
          cacheTtl: const Duration(minutes: 5),
        );
        final rows = response is Map ? response['operatingCompanies'] : null;
        if (rows is! List || rows.isEmpty) break;
        options.addAll(rows
            .whereType<Map>()
            .map((row) => _FilterOption(
                  row['id']?.toString() ?? '',
                  row['name']?.toString() ?? '',
                ))
            .where((row) => row.id.isNotEmpty));
        offset += rows.length;
        final metadata = response is Map ? response['meta'] : null;
        final total = metadata is Map
            ? int.tryParse(metadata['total']?.toString() ?? '')
            : null;
        if (rows.length < pageSize || (total != null && offset >= total)) break;
      }
      return options;
    } catch (_) {
      return const [];
    }
  }

  Future<List<_FilterOption>> projects() async {
    try {
      const pageSize = 200;
      final options = <_FilterOption>[];
      var offset = 0;
      while (true) {
        final page = await AppServices.projects.listProjectsPage(
          limit: pageSize,
          offset: offset,
          view: 'select',
          cacheTtl: const Duration(minutes: 5),
        );
        options.addAll(page.projects
            .map((project) => _FilterOption(project.id, project.name)));
        offset += page.projects.length;
        if (page.projects.isEmpty ||
            offset >= page.meta.total ||
            page.projects.length < pageSize) {
          break;
        }
      }
      return options;
    } catch (_) {
      return const [];
    }
  }

  final results = await Future.wait([clients(), operators(), projects()]);
  return _FilterOptions(results[0], results[1], results[2]);
}

Future<FinanceQuery?> showFinanceFilters(
  BuildContext context,
  FinanceQuery query, {
  bool includeStatus = true,
  bool includeCategory = false,
  bool includeDates = true,
}) =>
    showModalBottomSheet<FinanceQuery>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.pageBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _FinanceFilterSheet(
        query: query,
        includeStatus: includeStatus,
        includeCategory: includeCategory,
        includeDates: includeDates,
      ),
    );

class _FinanceFilterSheet extends StatefulWidget {
  final FinanceQuery query;
  final bool includeStatus;
  final bool includeCategory;
  final bool includeDates;

  const _FinanceFilterSheet({
    required this.query,
    required this.includeStatus,
    required this.includeCategory,
    required this.includeDates,
  });

  @override
  State<_FinanceFilterSheet> createState() => _FinanceFilterSheetState();
}

class _FinanceFilterSheetState extends State<_FinanceFilterSheet> {
  late FinanceQuery _query;
  late final Future<_FilterOptions> _options;
  late final Future<List<int>> _years;

  @override
  void initState() {
    super.initState();
    _query = widget.query;
    _options = _loadOptions();
    _years = AppServices.finance
        .availableYears(
          cacheTtl: const Duration(minutes: 5),
        )
        .catchError((_) => <int>[]);
  }

  Future<void> _pickDate({required bool start}) async {
    final current =
        DateTime.tryParse(start ? _query.from ?? '' : _query.to ?? '');
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final value =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    setState(() => _query =
        start ? _query.copyWith(from: value) : _query.copyWith(to: value));
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: DraggableScrollableSheet(
            initialChildSize: .85,
            minChildSize: .5,
            maxChildSize: .96,
            expand: false,
            builder: (context, scrollController) => Column(children: [
              const SizedBox(height: 10),
              Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(4))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(children: [
                  Expanded(
                      child: Text(
                          context.tr(
                              en: 'Financial filters', ar: 'فلاتر المالية'),
                          style: const TextStyle(
                              fontSize: 21, fontWeight: FontWeight.w900))),
                  TextButton(
                    onPressed: () => setState(() {
                      _query = FinanceQuery(
                          year: widget.query.year,
                          quarter: widget.query.quarter,
                          pageSize: widget.query.pageSize);
                    }),
                    child: Text(context.tr(en: 'Reset', ar: 'إعادة تعيين')),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      FutureBuilder<List<int>>(
                        future: _years,
                        builder: (context, snapshot) => FinancePeriodPicker(
                          year: _query.year,
                          quarter: _query.quarter,
                          availableYears:
                              snapshot.data ?? [DateTime.now().year],
                          onYearChanged: (year) => setState(() => _query =
                              year == null
                                  ? _query.copyWith(
                                      clearYear: true, quarter: 'ALL')
                                  : _query.copyWith(year: year)),
                          onQuarterChanged: (quarter) => setState(
                              () => _query = _query.copyWith(quarter: quarter)),
                        ),
                      ),
                      if (widget.includeDates) ...[
                        const SizedBox(height: 14),
                        Row(children: [
                          Expanded(
                              child: _DateField(
                                  title: context.tr(en: 'From', ar: 'من'),
                                  value: _query.from,
                                  onTap: () => _pickDate(start: true),
                                  onClear: () => setState(() => _query =
                                      _query.copyWith(clearFrom: true)))),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _DateField(
                                  title: context.tr(en: 'To', ar: 'إلى'),
                                  value: _query.to,
                                  onTap: () => _pickDate(start: false),
                                  onClear: () => setState(() => _query =
                                      _query.copyWith(clearTo: true)))),
                        ]),
                      ],
                      const SizedBox(height: 14),
                      FutureBuilder<_FilterOptions>(
                        future: _options,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const LinearProgressIndicator();
                          }
                          final options = snapshot.data!;
                          return Column(children: [
                            _OptionField(
                              title: context.tr(en: 'Client', ar: 'العميل'),
                              value: _query.clientId,
                              options: options.clients,
                              onChanged: (value) => setState(() => _query =
                                  value == null
                                      ? _query.copyWith(clearClient: true)
                                      : _query.copyWith(clientId: value)),
                            ),
                            const SizedBox(height: 12),
                            _OptionField(
                              title: context.tr(
                                  en: 'Operating company',
                                  ar: 'الشركة المشغلة'),
                              value: _query.operatingCompanyId,
                              options: options.operators,
                              onChanged: (value) => setState(() => _query =
                                  value == null
                                      ? _query.copyWith(
                                          clearOperatingCompany: true)
                                      : _query.copyWith(
                                          operatingCompanyId: value)),
                            ),
                            const SizedBox(height: 12),
                            _OptionField(
                              title: context.tr(en: 'Project', ar: 'المشروع'),
                              value: _query.projectId,
                              options: options.projects,
                              onChanged: (value) => setState(() => _query =
                                  value == null
                                      ? _query.copyWith(clearProject: true)
                                      : _query.copyWith(projectId: value)),
                            ),
                          ]);
                        },
                      ),
                      if (widget.includeStatus) ...[
                        const SizedBox(height: 12),
                        _OptionField(
                          title: context.tr(
                              en: 'Project status', ar: 'حالة المشروع'),
                          value: _query.status,
                          options: [
                            _FilterOption('COMPLETED',
                                context.tr(en: 'Completed', ar: 'مكتمل')),
                            _FilterOption('ON_TRACK',
                                context.tr(en: 'On track', ar: 'على المسار')),
                            _FilterOption('AT_RISK',
                                context.tr(en: 'At risk', ar: 'معرّض للخطر')),
                            _FilterOption('OFF_TRACK',
                                context.tr(en: 'Off track', ar: 'خارج المسار')),
                          ],
                          onChanged: (value) => setState(() => _query =
                              value == null
                                  ? _query.copyWith(clearStatus: true)
                                  : _query.copyWith(status: value)),
                        ),
                      ],
                      if (widget.includeCategory) ...[
                        const SizedBox(height: 12),
                        _OptionField(
                          title: context.tr(
                              en: 'Cost category', ar: 'فئة التكلفة'),
                          value: _query.costCategory,
                          options: [
                            if (_query.costCategory != null &&
                                _query.costCategory != 'TEAM' &&
                                _query.costCategory != 'OTHER')
                              _FilterOption(
                                  _query.costCategory!,
                                  financeCostCategory(
                                      context, _query.costCategory)),
                            _FilterOption(
                                'TEAM',
                                context.tr(
                                    en: 'Team costs', ar: 'تكاليف الفريق')),
                            _FilterOption(
                                'OTHER',
                                context.tr(
                                    en: 'Other costs', ar: 'تكاليف أخرى')),
                          ],
                          onChanged: (value) => setState(() => _query =
                              value == null
                                  ? _query.copyWith(clearCostCategory: true)
                                  : _query.copyWith(costCategory: value)),
                        ),
                      ],
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(_query.copyWith(page: 1));
                      },
                      child: Text(
                          context.tr(en: 'Apply filters', ar: 'تطبيق الفلاتر')),
                    )),
              ),
            ]),
          ),
        ),
      );
}

class _DateField extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DateField(
      {required this.title,
      required this.value,
      required this.onTap,
      required this.onClear});

  @override
  Widget build(BuildContext context) => FinanceSurface(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(value == null ? '—' : financeDate(value)),
                ),
              ),
            ),
            if (value != null)
              IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18)),
          ]),
        ]),
      );
}

class _OptionField extends StatelessWidget {
  final String title;
  final String? value;
  final List<_FilterOption> options;
  final ValueChanged<String?> onChanged;
  const _OptionField(
      {required this.title,
      required this.value,
      required this.options,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final selected = options.any((option) => option.id == value) ? value : null;
    return DropdownButtonFormField<String>(
      key: ValueKey('$title-${selected ?? ''}'),
      initialValue: selected ?? '',
      isExpanded: true,
      decoration: InputDecoration(labelText: title),
      items: [
        DropdownMenuItem(
            value: '', child: Text(context.tr(en: 'All', ar: 'الكل'))),
        ...options.map((option) => DropdownMenuItem(
            value: option.id,
            child: Text(option.name, overflow: TextOverflow.ellipsis))),
      ],
      onChanged: (value) =>
          onChanged(value == null || value.isEmpty ? null : value),
    );
  }
}
