import 'package:flutter/material.dart';

import '../../../data/models/org_user.dart';
import '../../../services/app_services.dart';
import '../../../theme/app_theme.dart';

class CreateTaskUserPickerSheet extends StatefulWidget {
  final List<OrgUser> initialItems;
  final int initialTotal;
  final int pageSize;

  const CreateTaskUserPickerSheet({
    super.key,
    required this.initialItems,
    required this.initialTotal,
    required this.pageSize,
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
            ListTile(
              title: const Text(
                'بدون إسناد',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text('إلغاء اختيار الشخص'),
              onTap: () => Navigator.of(context).pop(null),
            ),
            const Divider(height: 1),
            const SizedBox(height: 10),
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'ابحث عن موظف',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: items.isEmpty
                  ? Center(
                      child: _loadingMore && _users.isEmpty
                          ? const CircularProgressIndicator()
                          : const Text(
                              'لا توجد نتائج',
                              style: TextStyle(color: AppTheme.muted),
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
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            u.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => Navigator.of(context).pop(u),
                        );
                      },
                    ),
            ),
            if (hasMore) ...[
              const SizedBox(height: 10),
              _loadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: CircularProgressIndicator(),
                    )
                  : OutlinedButton(
                      onPressed: () => _loadMore(reset: false),
                      child: Text('تحميل المزيد (${_users.length}/$_total)'),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}
