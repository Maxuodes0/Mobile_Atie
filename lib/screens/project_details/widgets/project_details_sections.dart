import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../../data/models/project_collection.dart';
import '../../../data/models/project_team_member.dart';
import '../../../data/models/project_role_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/formatters.dart';
import '../../../utils/project_status.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/project_image.dart';
import '../../user_profile_screen.dart';

class ProjectValueSection extends StatelessWidget {
  final bool loading;
  final double? valueWithoutVat;
  final double? valueWithVat;

  const ProjectValueSection({
    super.key,
    required this.loading,
    required this.valueWithoutVat,
    required this.valueWithVat,
  });

  String _money(double? value) =>
      value == null ? '—' : formatSar(value.toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaRow(
          label: context.tr(
            en: 'Project value excluding VAT',
            ar: 'قيمة المشروع بدون ضريبة',
          ),
          value: _money(valueWithoutVat),
        ),
        const Divider(height: 20),
        _MetaRow(
          label: context.tr(
            en: 'Project value including VAT',
            ar: 'قيمة المشروع مع الضريبة',
          ),
          value: _money(valueWithVat),
        ),
        if (loading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }
}

class ProjectCostSection extends StatelessWidget {
  final bool loading;
  final double? totalCost;

  const ProjectCostSection({
    super.key,
    required this.loading,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final value = totalCost;
    final valueText = value == null ? '—' : formatSar(value.toStringAsFixed(2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaRow(
          label: context.tr(en: 'Total costs', ar: 'إجمالي التكاليف'),
          value: valueText,
        ),
        if (loading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(minHeight: 2),
        ],
      ],
    );
  }
}

class ProjectDetailsHeaderCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? client;
  final String? operatingCompanyName;
  final String? operatingCompanyNameEn;
  final String status;
  final String projectType;
  final DateTime? startDate;
  final DateTime? dueDate;
  final bool loading;

  const ProjectDetailsHeaderCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.client,
    required this.operatingCompanyName,
    required this.operatingCompanyNameEn,
    required this.status,
    required this.projectType,
    required this.startDate,
    required this.dueDate,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    String? fmt(DateTime? date) => date == null
        ? null
        : toLatinDigits(
            intl.DateFormat.yMMMd(locale.toString()).format(date.toLocal()),
          );

    final statusLabel = projectStatusLabel(
      status,
      languageCode: locale.languageCode,
    );
    final statusColor = projectStatusColor(status);
    final typeLabel = projectTypeLabel(
      projectType,
      languageCode: locale.languageCode,
    );
    final isArabic = locale.languageCode == 'ar';
    final localizedOperatingCompanyName = isArabic
        ? operatingCompanyName
        : ((operatingCompanyNameEn?.trim().isNotEmpty ?? false)
            ? operatingCompanyNameEn
            : operatingCompanyName);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ProjectImage(
              url: imageUrl,
              borderRadius: BorderRadius.circular(16),
              iconSize: 28,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? '-' : name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacitySafe(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            client ?? context.tr(en: 'No client', ar: 'بدون عميل'),
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (localizedOperatingCompanyName?.trim().isNotEmpty ?? false)
            _MetaRow(
              label: context.tr(
                en: 'Operating company',
                ar: 'الشركة المشغلة',
              ),
              value: localizedOperatingCompanyName!,
            ),
          _MetaRow(
            label: context.tr(en: 'Project type', ar: 'نوع المشروع'),
            value: typeLabel,
          ),
          if (startDate != null)
            _MetaRow(
              label: context.tr(en: 'Start', ar: 'البداية'),
              value: fmt(startDate) ?? '-',
            ),
          if (dueDate != null)
            _MetaRow(
              label: context.tr(en: 'Delivery', ar: 'التسليم'),
              value: fmt(dueDate) ?? '-',
            ),
          if (loading) ...[
            const SizedBox(height: 10),
            const LinearProgressIndicator(minHeight: 2),
          ],
        ],
      ),
    );
  }
}

class ProjectDetailsSectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ProjectDetailsSectionCard({
    super.key,
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class ProjectTeamSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final List<ProjectTeamMember> items;
  final List<ProjectRoleLabel> roleLabels;

  const ProjectTeamSection({
    super.key,
    required this.loading,
    required this.error,
    required this.items,
    required this.roleLabels,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Text(
        context.tr(
          en: 'Could not load the project team: $error',
          ar: 'تعذر تحميل فريق المشروع: $error',
        ),
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }
    if (items.isEmpty) {
      return Text(
        context.tr(
          en: 'No project team members',
          ar: 'لا يوجد أعضاء في فريق المشروع',
        ),
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }

    return Column(
      children: [
        for (final member in items) ...[
          _TeamMemberRow(member: member, roleLabels: roleLabels),
          if (member != items.last) const Divider(height: 18),
        ],
      ],
    );
  }
}

class ProjectCollectionsSection extends StatelessWidget {
  final bool loading;
  final String? error;
  final double totalCollected;
  final List<ProjectCollectionItem> items;

  const ProjectCollectionsSection({
    super.key,
    required this.loading,
    required this.error,
    required this.totalCollected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    String fmtDate(DateTime? date) => date == null
        ? '—'
        : toLatinDigits(
            intl.DateFormat.yMMMd(locale.toString()).format(date.toLocal()),
          );

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Text(
        context.tr(
          en: 'Could not load collections: $error',
          ar: 'تعذر تحميل التحصيل: $error',
        ),
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }
    if (items.isEmpty) {
      return Text(
        context.tr(
          en: 'No collections recorded',
          ar: 'لا توجد عمليات تحصيل مسجلة',
        ),
        style: const TextStyle(color: AppTheme.muted, fontSize: 12),
      );
    }

    final totalStr = totalCollected.toStringAsFixed(2);
    final shown = items.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetaRow(
          label: context.tr(en: 'Total collected', ar: 'إجمالي المحصل'),
          value: formatSar(totalStr),
        ),
        const SizedBox(height: 10),
        for (final collection in shown) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  fmtDate(collection.collectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatSar(collection.collectedAmount.toStringAsFixed(2)),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (collection != shown.last) const Divider(height: 18),
        ],
        if (items.length > shown.length)
          Text(
            context.tr(
              en: 'Showing ${shown.length} of ${items.length}',
              ar: 'عرض ${shown.length} من ${items.length}',
            ),
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberRow extends StatelessWidget {
  final ProjectTeamMember member;
  final List<ProjectRoleLabel> roleLabels;

  const _TeamMemberRow({required this.member, required this.roleLabels});

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    final name = (user?.name ?? '').trim();
    final projectRole = (member.projectRole ?? '').trim();
    final roleLabel = projectRole.isNotEmpty
        ? _localizedProjectRole(context, projectRole, roleLabels)
        : context.tr(en: 'No role', ar: 'بدون دور');

    final chipColor =
        member.isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final chipLabel = member.isPaid
        ? context.tr(en: 'Paid', ar: 'مدفوع')
        : context.tr(en: 'Unpaid', ar: 'غير مدفوع');

    final initials = name.isEmpty ? '?' : name.characters.first;

    final computedAmount = member.totalAmount ??
        (member.estimatedDays != null && member.dailyRate != null
            ? member.estimatedDays! * member.dailyRate!
            : null);
    final amountText = computedAmount == null
        ? '—'
        : formatSar(computedAmount.toStringAsFixed(2));

    const chevron = Icons.chevron_right;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final userId = member.userId.trim();
          if (userId.isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(
                userId: userId,
                initialName: name.isEmpty ? null : name,
                initialProjectRole: projectRole.isEmpty ? null : roleLabel,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF2F3F5),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.muted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name.isEmpty ? '—' : name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: chipColor.withOpacitySafe(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chipLabel,
                            style: TextStyle(
                              color: chipColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            roleLabel,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          amountText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(chevron, color: AppTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}

String _localizedProjectRole(
  BuildContext context,
  String value,
  List<ProjectRoleLabel> roleLabels,
) {
  for (final role in roleLabels) {
    if (role.matches(value)) {
      return role.localized(Localizations.localeOf(context).languageCode);
    }
  }
  final normalized = value.trim().toLowerCase();
  const roles = <String, ({String en, String ar})>{
    'project manager': (en: 'Project Manager', ar: 'مدير المشروع'),
    'manager': (en: 'Manager', ar: 'مدير'),
    'photographer': (en: 'Photographer', ar: 'مصور'),
    'videographer': (en: 'Videographer', ar: 'مصور فيديو'),
    'editor': (en: 'Editor', ar: 'مونتير'),
    'designer': (en: 'Designer', ar: 'مصمم'),
    'producer': (en: 'Producer', ar: 'منتج'),
    'director': (en: 'Director', ar: 'مخرج'),
    'assistant': (en: 'Assistant', ar: 'مساعد'),
    'live broadcast': (en: 'Live Broadcast', ar: 'بث مباشر'),
    'coverage': (en: 'Coverage', ar: 'تغطية'),
    'interviews': (en: 'Interviews', ar: 'لقاءات'),
    'television filming': (en: 'Television Filming', ar: 'تصوير تلفزيوني'),
  };
  final translated = roles[normalized];
  if (translated == null) return value;
  return context.tr(en: translated.en, ar: translated.ar);
}
