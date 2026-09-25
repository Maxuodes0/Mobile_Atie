import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/project_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class CreateTaskProjectPickerSheet extends StatefulWidget {
  final List<ProjectSummary> items;
  final String? selectedId;

  const CreateTaskProjectPickerSheet({
    super.key,
    required this.items,
    this.selectedId,
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

    final media = MediaQuery.of(context);
    final available = math.max(160.0,
        media.size.height - media.padding.top - media.viewInsets.bottom - 48);
    final height =
        math.min(560.0, math.min(media.size.height * .75, available));
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  context.tr(en: 'Select project', ar: 'اختر المشروع'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 12),
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
              Expanded(
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              p.clientName ??
                                  context.tr(en: 'No client', ar: 'بدون عميل'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: p.id == widget.selectedId
                                ? Icon(Icons.check_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(p),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
