import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data/models/org_user.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_services.dart';
import '../../../theme/app_theme.dart';

class CreateTaskUserPickerSheet extends StatefulWidget {
  final List<OrgUser> initialItems;
  final int initialTotal;
  final int pageSize;
  final String? selectedId;

  const CreateTaskUserPickerSheet({
    super.key,
    required this.initialItems,
    required this.initialTotal,
    required this.pageSize,
    this.selectedId,
  });

  @override
  State<CreateTaskUserPickerSheet> createState() =>
      _CreateTaskUserPickerSheetState();
}

class _CreateTaskUserPickerSheetState extends State<CreateTaskUserPickerSheet> {
  final _search = TextEditingController();

  List<OrgUser> _users = const [];
  int _total = 0;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _users = widget.initialItems;
    _total = widget.initialTotal;
    if (_users.isEmpty) {
      // Keep picker usable when parent prefetch fails.
      _loadMore(reset: true);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasMore => _users.length < _total;

  Future<void> _loadMore({required bool reset}) async {
    if (_loadingMore) return;
    if (!reset && !_hasMore) return;

    setState(() => _loadingMore = true);
    try {
      final res = await AppServices.users.listMyOrganizationUsers(
        limit: widget.pageSize,
        offset: reset ? 0 : _users.length,
        view: 'basic',
      );
      if (!mounted) return;
      setState(() {
        _users = reset ? res.users : [..._users, ...res.users];
        _total = res.meta.total;
      });
    } catch (_) {
      // Ignore error to preserve already loaded choices.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final items = q.isEmpty
        ? _users
        : _users.where((u) {
            final name = u.name.toLowerCase();
            final email = u.email.toLowerCase();
            return name.contains(q) || email.contains(q);
          }).toList();

    final hasMore = _hasMore;

    final media = MediaQuery.of(context);
    final available = math.max(180.0,
        media.size.height - media.padding.top - media.viewInsets.bottom - 48);
    final height =
        math.min(580.0, math.min(media.size.height * .78, available));
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
                  context.tr(en: 'Select assignee', ar: 'اختر الشخص'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              const SizedBox(height: 8),
              if (media.viewInsets.bottom == 0) ...[
                ListTile(
                  title: Text(
                    context.tr(en: 'Unassigned', ar: 'بدون إسناد'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(context.tr(
                    en: 'Clear selected assignee',
                    ar: 'إلغاء اختيار الشخص',
                  )),
                  trailing: widget.selectedId == null
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(null),
                ),
                const Divider(height: 1),
                const SizedBox(height: 10),
              ],
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      context.tr(en: 'Search team members', ar: 'ابحث عن موظف'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: _loadingMore && _users.isEmpty
                            ? const CircularProgressIndicator()
                            : Text(
                                context.tr(
                                    en: 'No results', ar: 'لا توجد نتائج'),
                                style: const TextStyle(color: AppTheme.muted),
                              ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final u = items[index];
                          return ListTile(
                            title: Text(
                              u.name.isEmpty ? '—' : u.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              u.email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: u.id == widget.selectedId
                                ? Icon(Icons.check_rounded,
                                    color:
                                        Theme.of(context).colorScheme.primary)
                                : null,
                            onTap: () => Navigator.of(context).pop(u),
                          );
                        },
                      ),
              ),
              if (hasMore && media.viewInsets.bottom == 0) ...[
                const SizedBox(height: 10),
                _loadingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: CircularProgressIndicator(),
                      )
                    : OutlinedButton(
                        onPressed: () => _loadMore(reset: false),
                        child: Text(context.tr(
                          en: 'Load more (${_users.length}/$_total)',
                          ar: 'تحميل المزيد (${_users.length}/$_total)',
                        )),
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
