import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../data/models/client_summary.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/async_request_guard_mixin.dart';
import '../widgets/app_page_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/inline_loading_bar.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen>
    with AsyncRequestGuardMixin<ClientsScreen> {
  final _searchController = TextEditingController();
  bool _loading = true;
  bool _updating = false;
  String? _error;
  List<ClientSummary> _clients = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<void> _load({bool forceRefresh = false}) async {
    final ticket = nextRequestTicket();
    setState(() {
      _error = null;
      if (_clients.isEmpty) {
        _loading = true;
      } else {
        _updating = true;
      }
    });

    try {
      final clients = await AppServices.clients.listAllClients(
        cacheTtl: const Duration(seconds: 45),
        forceRefresh: forceRefresh,
      );
      if (isRequestStale(ticket)) return;
      setState(() => _clients = clients);
    } catch (error) {
      if (isRequestStale(ticket)) return;
      setState(() => _error = error.toString());
    } finally {
      if (!isRequestStale(ticket)) {
        setState(() {
          _loading = false;
          _updating = false;
        });
      }
    }
  }

  List<ClientSummary> get _filteredClients {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _clients;
    return _clients
        .where((client) => client.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  int get _totalProjects =>
      _clients.fold(0, (sum, client) => sum + client.projectCount);

  double get _totalValue => _clients.fold(
        0,
        (sum, client) => sum + client.totalRevenueWithoutVat,
      );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    final clients = _filteredClients;
    final averageValue = _clients.isEmpty ? 0.0 : _totalValue / _clients.length;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const AppPageHeader(
              title: 'العملاء',
              subtitle: 'قائمة العملاء وإحصائيات المشاريع',
            ),
            InlineLoadingBar(visible: _updating),
            const SizedBox(height: 16),
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            SizedBox(
              height: 132,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _StatisticCard(
                    title: 'إجمالي العملاء',
                    value: _clients.length.toString(),
                    icon: Icons.groups_rounded,
                    color: AppTheme.accent,
                  ),
                  _StatisticCard(
                    title: 'إجمالي المشاريع',
                    value: _totalProjects.toString(),
                    icon: Icons.folder_copy_rounded,
                    color: const Color(0xFF4F7CAC),
                  ),
                  _StatisticCard(
                    title: 'القيمة بدون الضريبة',
                    value: _formatSar(_totalValue),
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFB7791F),
                    wide: true,
                  ),
                  _StatisticCard(
                    title: 'متوسط قيمة العميل',
                    value: _formatSar(averageValue),
                    icon: Icons.insights_rounded,
                    color: const Color(0xFF7C5CBF),
                    wide: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن عميل',
                prefixIcon: Icon(Icons.search, size: 20),
                prefixIconColor: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 16),
            if (clients.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'لا يوجد عملاء',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                ),
              )
            else
              ...clients.map((client) => _ClientCard(client: client)),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? 210 : 160,
      margin: const EdgeInsetsDirectional.only(end: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacitySafe(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.muted.withOpacitySafe(0.45),
                size: 13,
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(color: AppTheme.muted, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ClientSummary client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          _ClientAvatar(client: client),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ClientMetric(
                      icon: Icons.folder_open_rounded,
                      label: '${client.projectCount} مشروع',
                    ),
                    _ClientMetric(
                      icon: Icons.payments_outlined,
                      label:
                          '${_formatSar(client.totalRevenueWithoutVat)} بدون ضريبة',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientAvatar extends StatelessWidget {
  final ClientSummary client;

  const _ClientAvatar({required this.client});

  @override
  Widget build(BuildContext context) {
    final logo = client.logo?.trim();
    final initial = client.name.trim().isEmpty ? 'ع' : client.name.trim()[0];

    if (logo != null && logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          logo,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialAvatar(initial: initial),
        ),
      );
    }
    return _InitialAvatar(initial: initial);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;

  const _InitialAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacitySafe(0.13),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ClientMetric extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ClientMetric({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.muted, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

final intl.NumberFormat _sarFormatter = intl.NumberFormat('#,##0.##', 'en_US');

String _formatSar(double value) => '${_sarFormatter.format(value)} ر.س';
