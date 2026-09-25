import 'package:flutter/material.dart';

import '../../data/models/finance_module.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'finance_ui.dart';

class FinanceQueryBar extends StatefulWidget {
  final String? initialSearch;
  final ValueChanged<String> onSearch;
  final VoidCallback onFilters;
  const FinanceQueryBar(
      {super.key,
      required this.initialSearch,
      required this.onSearch,
      required this.onFilters});

  @override
  State<FinanceQueryBar> createState() => _FinanceQueryBarState();
}

class _FinanceQueryBarState extends State<FinanceQueryBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialSearch ?? '');
  }

  @override
  void didUpdateWidget(covariant FinanceQueryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearch != widget.initialSearch) {
      _search.text = widget.initialSearch ?? '';
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onSubmitted: widget.onSearch,
          decoration: InputDecoration(
            hintText: context.tr(en: 'Search', ar: 'بحث'),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              tooltip: context.tr(en: 'Search', ar: 'بحث'),
              onPressed: () => widget.onSearch(_search.text),
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        )),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          key: const ValueKey('finance-filter-button'),
          tooltip: context.tr(en: 'Filters', ar: 'الفلاتر'),
          onPressed: widget.onFilters,
          icon: const Icon(Icons.tune_rounded),
        ),
      ]);
}

class FinanceResults extends StatelessWidget {
  final FinanceDataPage? data;
  final String? error;
  final bool loading;
  final VoidCallback onRetry;
  final ValueChanged<int> onPage;
  final Widget Function(BuildContext, Map<String, dynamic>) rowBuilder;
  final Widget? header;

  const FinanceResults({
    super.key,
    required this.data,
    required this.error,
    required this.loading,
    required this.onRetry,
    required this.onPage,
    required this.rowBuilder,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    if (loading && data == null) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (error != null) {
      return FinanceErrorState(message: error, onRetry: onRetry);
    }
    final result = data;
    if (result == null) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (header != null) ...[header!, const SizedBox(height: 14)],
      if (loading) const LinearProgressIndicator(minHeight: 2),
      const SizedBox(height: 10),
      if (result.rows.isEmpty)
        FinanceEmptyState(
            message: context.tr(
                en: 'No matching financial records',
                ar: 'لا توجد سجلات مالية مطابقة'))
      else
        ...result.rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: rowBuilder(context, row),
            )),
      if (result.meta.totalPages > 1)
        FinancePageFooter(meta: result.meta, onPageChanged: onPage),
      if (result.rows.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
              context.tr(
                en: '${result.meta.total} matching records',
                ar: '${result.meta.total} سجل مطابق',
              ),
              style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
        ),
    ]);
  }
}
