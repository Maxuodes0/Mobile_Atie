import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../data/models/user_profile.dart';
import '../data/models/user_project_summary.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/user_avatar.dart';
import 'project_details_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? initialName;
  final String? initialProjectRole;

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.initialName,
    this.initialProjectRole,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _loading = true;
  String? _error;
  UserProfile? _profile;
  UserProjectSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        AppServices.users.getUser(userId: widget.userId),
        AppServices.users.getTeamSummary(userId: widget.userId),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = results[0] as UserProfile;
        _summary = results[1] as UserProjectSummary;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    String fmtDate(DateTime? d) => d == null
        ? '—'
        : intl.DateFormat.yMMMd(locale.toString()).format(d.toLocal());

    final profile = _profile;
    final summary = _summary;

    final displayName = (profile?.name ?? widget.initialName ?? '').trim();
    final initials =
        displayName.isEmpty ? '?' : displayName.characters.first.toUpperCase();
    final accountRole = (profile?.role ?? '').trim();
    final projectRole = (widget.initialProjectRole ?? '').trim();

    final title = displayName.isEmpty ? 'ملف الموظف' : displayName;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              _HeaderCard(
                loading: _loading && profile == null,
                name: displayName.isEmpty ? '—' : displayName,
                initials: initials,
                imageUrl: profile?.profileImage,
                role: accountRole.isEmpty ? null : accountRole,
                projectRole: projectRole.isEmpty ? null : projectRole,
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'معلومات التواصل',
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.mail_outline,
                      label: 'البريد',
                      value: (profile?.email ?? '').trim(),
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'الجوال',
                      value: (profile?.phone ?? '').trim(),
                      fallback: '—',
                    ),
                    _InfoRow(
                      icon: Icons.credit_card_outlined,
                      label: 'الآيبان',
                      value: (profile?.iban ?? '').trim(),
                      fallback: '—',
                    ),
                    _InfoRow(
                      icon: Icons.apartment_outlined,
                      label: 'المنظمة',
                      value: (profile?.organizationName ?? '').trim(),
                      fallback: '—',
                    ),
                    _InfoRow(
                      icon: Icons.calendar_month_outlined,
                      label: 'تاريخ التسجيل',
                      value: fmtDate(profile?.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (profile?.hrProfile != null)
                _SectionCard(
                  title: 'بيانات وظيفية',
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'رقم الموظف',
                        value: (profile!.hrProfile!.employeeNumber ?? '').trim(),
                        fallback: '—',
                      ),
                      _InfoRow(
                        icon: Icons.work_outline,
                        label: 'المسمى',
                        value: (profile.hrProfile!.jobTitle ?? '').trim(),
                        fallback: '—',
                      ),
                      _InfoRow(
                        icon: Icons.account_tree_outlined,
                        label: 'القسم',
                        value: (profile.hrProfile!.department ?? '').trim(),
                        fallback: '—',
                      ),
                      _InfoRow(
                        icon: Icons.verified_outlined,
                        label: 'الحالة',
                        value: (profile.hrProfile!.status ?? '').trim(),
                        fallback: '—',
                      ),
                      _InfoRow(
                        icon: Icons.date_range_outlined,
                        label: 'تاريخ التعيين',
                        value: fmtDate(profile.hrProfile!.hireDate),
                      ),
                    ],
                  ),
                ),
              if (profile?.hrProfile != null) const SizedBox(height: 14),
              _SectionCard(
                title: 'إحصائيات',
                child: summary == null && _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _StatsGrid(
                        totalProjects: summary?.totalProjects ?? 0,
                        paidProjects: summary?.paidProjects ?? 0,
                        unpaidProjects: summary?.unpaidProjects ?? 0,
                        totalPaidAmount: summary?.totalPaidAmount ?? 0,
                      ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'المشاريع',
                child: summary == null && _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _ProjectsList(
                        items: summary?.projects ?? const [],
                      ),
              ),
              if (_loading && profile == null)
                const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool loading;
  final String name;
  final String initials;
  final String? imageUrl;
  final String? role;
  final String? projectRole;

  const _HeaderCard({
    required this.loading,
    required this.name,
    required this.initials,
    required this.imageUrl,
    required this.role,
    required this.projectRole,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge(String text) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacitySafe(0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          UserAvatar(imageUrl: imageUrl, initials: initials, radius: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (projectRole != null && projectRole!.trim().isNotEmpty)
                      badge(projectRole!.trim()),
                    if (role != null && role!.trim().isNotEmpty)
                      badge(role!.trim()),
                  ],
                ),
                if (loading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String fallback;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.fallback = '',
  });

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? fallback : value.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.muted),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              v.isEmpty ? '—' : v,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int totalProjects;
  final int paidProjects;
  final int unpaidProjects;
  final double totalPaidAmount;

  const _StatsGrid({
    required this.totalProjects,
    required this.paidProjects,
    required this.unpaidProjects,
    required this.totalPaidAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'إجمالي المشاريع',
                value: '$totalProjects',
                icon: Icons.work_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'مدفوعة',
                value: '$paidProjects',
                icon: Icons.verified_outlined,
                tint: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'غير مدفوعة',
                value: '$unpaidProjects',
                icon: Icons.error_outline,
                tint: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatTile(
                label: 'إجمالي المدفوع',
                value: formatSar(totalPaidAmount.toStringAsFixed(2)),
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? tint;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final c = tint ?? AppTheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withOpacitySafe(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: c.withOpacitySafe(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: c),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<UserProjectMembership> items;

  const _ProjectsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Text(
        'لا توجد بيانات مشاريع',
        style: TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }

    final shown = items.take(8).toList();
    return Column(
      children: [
        for (final p in shown) ...[
          _ProjectRow(item: p),
          if (p != shown.last) const Divider(height: 18),
        ],
        if (items.length > shown.length)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'عرض ${shown.length} من ${items.length}',
              style: const TextStyle(color: AppTheme.muted, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _ProjectRow extends StatelessWidget {
  final UserProjectMembership item;

  const _ProjectRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final chipColor =
        item.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final chipLabel = item.isPaid ? 'مدفوع' : 'غير مدفوع';

    final amount = item.amount ??
        (item.days != null && item.ratePerDay != null
            ? item.days! * item.ratePerDay!
            : null);
    final amountStr =
        amount == null ? '—' : formatSar(amount.toStringAsFixed(2));

    final direction = Directionality.of(context);
    final chevron =
        direction == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final id = item.projectId.trim();
          if (id.isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProjectDetailsScreen(projectId: id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.projectName.isEmpty ? '—' : item.projectName,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            (item.role ?? '').trim().isEmpty
                                ? 'بدون دور'
                                : item.role!.trim(),
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          amountStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor.withOpacitySafe(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  chipLabel,
                  style: TextStyle(
                    color: chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(chevron, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
