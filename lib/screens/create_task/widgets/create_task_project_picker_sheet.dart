import 'package:flutter/material.dart';

import '../../../data/models/project_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class CreateTaskProjectPickerSheet extends StatefulWidget {
  final List<ProjectSummary> items;

  const CreateTaskProjectPickerSheet({
    super.key,
    required this.items,
  });

  @override
  State<CreateTaskProjectPickerSheet> createState() =>
      _CreateTaskProjectPickerSheetState();
}

class _CreateTaskProjectPickerSheetState
    extends State<CreateTaskProjectPickerSheet> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final items = q.isEmpty
        ? widget.items
        : widget.items.where((p) {
            final name = p.name.toLowerCase();
            final client = (p.clientName ?? '').toLowerCase();
            return name.contains(q) || client.contains(q);
          }).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText:
                    context.tr(en: 'Search projects', ar: 'ابحث عن مشروع'),
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        context.tr(en: 'No results', ar: 'لا توجد نتائج'),
                        style: const TextStyle(color: AppTheme.muted),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return ListTile(
                          title: Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            p.clientName ??
                                context.tr(en: 'No client', ar: 'بدون عميل'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
